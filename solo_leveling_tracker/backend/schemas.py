from pydantic import BaseModel
from typing import Optional, List

# --- Inventory Schemas ---
class InventoryItemBase(BaseModel):
    name: str
    description: str
    rarity: str
    quantity: int
    item_type: Optional[str] = "material"

class InventoryItemResponse(InventoryItemBase):
    id: int

    class Config:
        orm_mode = True

# --- Task Schemas ---
class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    exp_reward: float = 10.0
    is_daily: bool = False

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    exp_reward: Optional[float] = None
    is_daily: Optional[bool] = None

class TaskResponse(TaskBase):
    id: int
    completed: bool

    class Config:
        orm_mode = True

# --- Skill Schemas ---
class SkillBase(BaseModel):
    name: str
    description: str
    mp_cost: int = 0
    is_passive: bool = False
    required_stat: Optional[str] = None

class SkillCreate(SkillBase):
    pass

class SkillResponse(SkillBase):
    id: int
    unlocked: bool

    class Config:
        orm_mode = True

# --- User Schemas ---
class UserBase(BaseModel):
    name: str
    job_class: str
    title: str
    level: int
    exp: float
    required_exp: float
    hp: int
    max_hp: int
    mp: int
    max_mp: int
    strength: int
    agility: int
    sense: int
    vitality: int
    intelligence: int
    available_stat_points: int

class UserUpdateProfile(BaseModel):
    name: Optional[str] = None
    job_class: Optional[str] = None
    title: Optional[str] = None

class UserUpdateStats(BaseModel):
    strength: Optional[int] = None
    agility: Optional[int] = None
    sense: Optional[int] = None
    vitality: Optional[int] = None
    intelligence: Optional[int] = None

class UserResponse(UserBase):
    id: int

    class Config:
        orm_mode = True
