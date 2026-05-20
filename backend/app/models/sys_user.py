from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from app.core.database import Base


class SysUser(Base):
    """用户表"""
    __tablename__ = 'sys_user'

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(64), unique=True, nullable=False, comment='用户名')
    password_hash = Column(String(256), nullable=False, comment='密码哈希')
    real_name = Column(String(64), comment='真实姓名')
    phone = Column(String(20), comment='手机号')
    email = Column(String(128), comment='邮箱')
    role_id = Column(Integer, ForeignKey('sys_role.id'), comment='角色ID')
    status = Column(Integer, default=1, comment='状态:1启用0禁用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
