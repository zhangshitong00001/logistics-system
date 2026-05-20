from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class SysOperationLog(Base):
    """操作日志表"""
    __tablename__ = 'sys_operation_log'

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(64), comment='操作人')
    module = Column(String(64), comment='操作模块')
    action = Column(String(64), comment='操作类型')
    target = Column(String(256), comment='操作对象')
    detail = Column(Text, comment='详细内容')
    ip_address = Column(String(64), comment='IP地址')
    duration_ms = Column(Integer, comment='耗时(毫秒)')
    status = Column(Integer, default=0, comment='状态:1成功0失败')
    create_time = Column(DateTime, server_default=func.now())
