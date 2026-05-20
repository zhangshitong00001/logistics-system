from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class DeliveryTask(Base):
    """配送任务表"""
    __tablename__ = 'delivery_task'

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_no = Column(String(64), unique=True, nullable=False, comment='配送单号')
    pickup_point_id = Column(Integer, ForeignKey('pickup_point.id'), comment='收件点ID')
    package_count = Column(Integer, default=0, comment='包裹数')
    batch_no = Column(String(64), comment='批次号')
    delivery_person = Column(String(64), comment='配送员')
    delivery_phone = Column(String(20), comment='配送员电话')
    status = Column(Integer, default=0, comment='状态:0待配送1配送中2已签收3异常')
    remark = Column(Text, comment='备注')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
