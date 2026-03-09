from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import math
import random

import models, schemas
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="System API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Leveling Algorithm
def calculate_required_exp(level: int) -> float:
    return math.pow(level * 100, 1.5)

def check_level_up(user: models.User):
    leveled_up = False
    while user.exp >= user.required_exp:
        user.exp -= user.required_exp
        user.level += 1
        user.required_exp = calculate_required_exp(user.level)
        user.available_stat_points += 5
        user.max_hp += 10
        user.hp = user.max_hp
        user.max_mp += 5
        user.mp = user.max_mp
        leveled_up = True
    return leveled_up

def seed_initial_data(db: Session):
    if not db.query(models.User).first():
        new_user = models.User(required_exp=calculate_required_exp(1))
        db.add(new_user)
        db.commit()
    if not db.query(models.Skill).first():
        default_skills = [
            models.Skill(name="Shadow Extraction", description="Extract shadows from fallen enemies to create shadow soldiers. Requires 50 INT.", mp_cost=30),
            models.Skill(name="Dominator's Touch", description="Instantly kill weak enemies. 25% chance on targets below 10% HP.", mp_cost=15),
            models.Skill(name="Ruler's Authority", description="Overwhelm enemies with immense pressure. Reduces their stats by 20%.", mp_cost=25),
            models.Skill(name="Mana Regen", description="Regenerate 5 MP per second for 10 seconds.", mp_cost=20),
        ]
        db.add_all(default_skills)
        db.commit()

@app.on_event("startup")
def startup_event():
    from sqlalchemy import text
    db = next(get_db())
    try:
        db.execute(text("ALTER TABLE inventory_items ADD COLUMN item_type VARCHAR DEFAULT 'material'"))
        db.commit()
    except Exception:
        db.rollback()  # Column may already exist
        
    seed_initial_data(db)

@app.get("/api/user", response_model=schemas.UserResponse)
def get_user(db: Session = Depends(get_db)):
    user = db.query(models.User).first()
    return user

@app.post("/api/user/add_exp", response_model=schemas.UserResponse)
def add_exp(amount: float, db: Session = Depends(get_db)):
    user = db.query(models.User).first()
    user.exp += amount
    check_level_up(user)
    db.commit()
    db.refresh(user)
    return user

@app.post("/api/user/assign_stats", response_model=schemas.UserResponse)
def assign_stats(stats: schemas.UserUpdateStats, db: Session = Depends(get_db)):
    user = db.query(models.User).first()
    
    total_requested = 0
    if stats.strength: total_requested += stats.strength
    if stats.agility: total_requested += stats.agility
    if stats.sense: total_requested += stats.sense
    if stats.vitality: total_requested += stats.vitality
    if stats.intelligence: total_requested += stats.intelligence
    
    if total_requested > user.available_stat_points:
        raise HTTPException(status_code=400, detail="Not enough stat points")
    
    if stats.strength: user.strength += stats.strength
    if stats.agility: user.agility += stats.agility
    if stats.sense: user.sense += stats.sense
    if stats.vitality: user.vitality += stats.vitality
    if stats.intelligence: user.intelligence += stats.intelligence
    
    user.available_stat_points -= total_requested
    db.commit()
    db.refresh(user)
    return user

@app.get("/api/system/briefing")
def get_system_briefing(db: Session = Depends(get_db)):
    uncompleted = db.query(models.Task).filter(models.Task.completed == False).limit(5).all()
    if uncompleted:
        msg = "SYSTEM AWAKENED. YOU HAVE PENDING OBJECTIVES."
    else:
        msg = "NO ACTIVE QUESTS. STANDBY FOR ASSIGNMENT."
    return {"message": msg, "tasks": uncompleted}
    db.refresh(user)
    return user

@app.put("/api/user/profile", response_model=schemas.UserResponse)
def update_profile(profile_data: schemas.UserUpdateProfile, db: Session = Depends(get_db)):
    user = db.query(models.User).first()
    if profile_data.name is not None:
        user.name = profile_data.name
    if profile_data.job_class is not None:
        user.job_class = profile_data.job_class
    if profile_data.title is not None:
        user.title = profile_data.title
    db.commit()
    db.refresh(user)
    return user

@app.get("/api/system/briefing")
def get_system_briefing(db: Session = Depends(get_db)):
    incomplete_dailies = db.query(models.Task).filter(
        models.Task.is_daily == True, 
        models.Task.completed == False
    ).all()
    
    if not incomplete_dailies:
        raise HTTPException(status_code=404, detail="No new messages")
        
    return {
        "message": "Player has incomplete daily quests. Failure to complete them will result in a penalty.",
        "tasks": [{"title": t.title, "exp_reward": t.exp_reward} for t in incomplete_dailies]
    }

@app.get("/api/tasks", response_model=List[schemas.TaskResponse])
def get_tasks(db: Session = Depends(get_db)):
    return db.query(models.Task).all()

@app.post("/api/tasks", response_model=schemas.TaskResponse)
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    db_task = models.Task(**task.dict())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.put("/api/tasks/{task_id}", response_model=schemas.TaskResponse)
def update_task(task_id: int, task_data: schemas.TaskUpdate, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    if db_task.completed and not db_task.is_daily:
        raise HTTPException(status_code=400, detail="Cannot edit completed task")
    data = task_data.dict(exclude_unset=True)
    for key, value in data.items():
        setattr(db_task, key, value)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.delete("/api/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted"}

@app.post("/api/tasks/{task_id}/complete")
def complete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.completed and not task.is_daily:
        raise HTTPException(status_code=400, detail="Task already completed")
    
    user = db.query(models.User).first()
    user.exp += task.exp_reward
    check_level_up(user)
    
    if task.category == 'coding' or task.category == 'studying':
        user.intelligence += 1 
    elif task.category == 'workout':
        user.strength += 1
        user.vitality += 1
    elif task.category == 'reading' or task.category == 'meditating':
        user.sense += 1
        
    # Item Drop Logic - Weapons, Stones, Consumables, Materials
    drop_message = None
    drop_chance = random.random()
    # 35% chance to drop an item
    if drop_chance <= 0.35:
        rarity_roll = random.random()
        # Item pool: (name, desc, rarity, item_type)
        if rarity_roll > 0.96:
            items = [
                ("Shadow Monarch's Blade", "A legendary sword that cuts through dimensions.", "S-Rank", "weapon"),
                ("Elixir of Eternal Life", "Grants permanent +2 to all stats. One-time use.", "S-Rank", "consumable"),
            ]
        elif rarity_roll > 0.88:
            items = [
                ("Demon Lord's Scythe", "An epic weapon forged in the depths of the dungeon.", "Epic", "weapon"),
                ("Enhancement Stone +9", "Upgrade any weapon or armor to +9.", "Epic", "stone"),
                ("Mana Crystal Shard", "Restores 50 MP when used.", "Epic", "consumable"),
                ("Phoenix Feather", "Revives with 50% HP. Rare crafting material.", "Epic", "material"),
            ]
        elif rarity_roll > 0.65:
            items = [
                ("Steel Longsword", "A well-crafted sword favored by knights.", "Rare", "weapon"),
                ("Mana Stone", "Increases max MP by 5 when absorbed.", "Rare", "stone"),
                ("Health Potion", "Restores 30 HP instantly.", "Rare", "consumable"),
                ("High Orc's Tooth", "Can be sold for gold or used to upgrade weapons.", "Rare", "material"),
            ]
        else:
            items = [
                ("Goblin's Dagger", "A rusty, slightly chipped dagger.", "Common", "weapon"),
                ("Iron Ore", "Basic crafting material for smithing.", "Common", "material"),
                ("Minor Mana Stone", "A small stone with trace mana.", "Common", "stone"),
                ("Bread", "Restores 10 HP. Common ration.", "Common", "consumable"),
            ]
        item_name, desc, rarity, item_type = random.choice(items)
            
        existing_item = db.query(models.InventoryItem).filter(models.InventoryItem.name == item_name).first()
        if existing_item:
            existing_item.quantity += 1
        else:
            new_item = models.InventoryItem(name=item_name, description=desc, rarity=rarity, quantity=1, item_type=item_type)
            db.add(new_item)
        
        drop_message = f"Dropped: [{rarity}] {item_name}!"
        
    task.completed = True
    db.commit()
    
    response_msg = {"message": "Task completed successfully", "exp_gained": task.exp_reward}
    if drop_message:
        response_msg["drop_message"] = drop_message
        
    return response_msg

@app.get("/api/inventory", response_model=List[schemas.InventoryItemResponse])
def get_inventory(db: Session = Depends(get_db)):
    return db.query(models.InventoryItem).all()

@app.get("/api/skills", response_model=List[schemas.SkillResponse])
def get_skills(db: Session = Depends(get_db)):
    return db.query(models.Skill).all()

@app.post("/api/skills", response_model=schemas.SkillResponse)
def create_skill(skill: schemas.SkillCreate, db: Session = Depends(get_db)):
    db_skill = models.Skill(**skill.dict())
    db.add(db_skill)
    db.commit()
    db.refresh(db_skill)
    return db_skill

@app.post("/api/skills/{skill_id}/cast")
def cast_skill(skill_id: int, db: Session = Depends(get_db)):
    skill = db.query(models.Skill).filter(models.Skill.id == skill_id).first()
    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found")
        
    user = db.query(models.User).first()
    if user.mp < skill.mp_cost:
        raise HTTPException(status_code=400, detail="Not enough MP")
        
    user.mp -= skill.mp_cost
    db.commit()
    return {"message": f"Cast {skill.name} successfully", "mp_cost": skill.mp_cost, "mp_remaining": user.mp}

@app.post("/api/system/reset")
def system_reset(db: Session = Depends(get_db)):
    # Wipe existing data
    db.query(models.Task).delete()
    db.query(models.InventoryItem).delete()
    db.query(models.Skill).delete()
    db.query(models.User).delete()
    db.commit()
    
    # Re-awaken the system with fresh data
    seed_initial_data(db)
    
    return {"status": "System Re-Awakening Initialized", "message": "All data has been wiped and restored to level 1."}
