from typing import Optional, List
from pydantic import BaseModel


# ====== Auth ======
class LoginRequest(BaseModel):
    username: str
    password: str
    captcha: Optional[str] = None

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    username: str
    real_name: Optional[str] = None
    role_id: Optional[int] = None

class UserInfo(BaseModel):
    id: int
    username: str
    real_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    role_id: Optional[int] = None

# ====== Common ======
class ApiResponse(BaseModel):
    code: int = 200
    message: str = "success"
    data: Optional[dict] = None

class PageParams(BaseModel):
    page: int = 1
    size: int = 20
    sort_field: Optional[str] = None
    sort_order: Optional[str] = "desc"

class PageResponse(BaseModel):
    records: List
    total: int
    page: int
    size: int
    pages: int


# ====== Auth Extras ======
class SendCodeRequest(BaseModel):
    email: str
    purpose: str = "login"

class RegisterRequest(BaseModel):
    username: str
    password: str
    real_name: str = ""
    phone: str = ""
    email: str = ""
    code: str = ""

class CodeLoginRequest(BaseModel):
    email: str
    code: str

class ResetPasswordRequest(BaseModel):
    email: str
    code: str
    new_password: str
