from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, default="Sung Jin-Woo")
    job_class = Column(String, default="None")
    title = Column(String, default="None")
    level = Column(Integer, default=1)
    exp = Column(Float, default=0.0)
    required_exp = Column(Float, default=100.0)
    
    hp = Column(Integer, default=100)
    max_hp = Column(Integer, default=100)
    mp = Column(Integer, default=10)
    max_mp = Column(Integer, default=10)
    
    # Core stats
    strength = Column(Integer, default=10)
    agility = Column(Integer, default=10)
    sense = Column(Integer, default=10)
    vitality = Column(Integer, default=10)
    intelligence = Column(Integer, default=10)
    available_stat_points = Column(Integer, default=0)

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String, nullable=True)
    category = Column(String) # e.g., 'coding', 'workout'
    exp_reward = Column(Float, default=10.0)
    is_daily = Column(Boolean, default=False)
    completed = Column(Boolean, default=False)

class Skill(Base):
    __tablename__ = "skills"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    mp_cost = Column(Integer, default=0)
    is_passive = Column(Boolean, default=False)
    unlocked = Column(Boolean, default=False)
    required_stat = Column(String, nullable=True) # e.g. 'intelligence:50'

class InventoryItem(Base):
    __tablename__ = "inventory_items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    rarity = Column(String, default="Common")  # Common, Rare, Epic, Legendary, S-Rank
    quantity = Column(Integer, default=1)
    item_type = Column(String, default="material")  # weapon, stone, consumable, material

