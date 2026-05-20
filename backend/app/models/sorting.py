from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class PickupPoint(Base):
    """收件点表"""
    __tablename__ = 'pickup_point'

    id = Column(Integer, primary_key=True, autoincrement=True)
    point_code = Column(String(64), unique=True, nullable=False, comment='收件点编号')
    point_name = Column(String(128), nullable=False, comment='收件点名称')
    address = Column(String(256), comment='地址')
    region = Column(String(64), comment='区域')
    contact_person = Column(String(64), comment='联系人')
    contact_phone = Column(String(20), comment='联系电话')
    coverage_status = Column(Integer, default=0, comment='覆盖状态:0未覆盖1已覆盖')
    status = Column(Integer, default=1, comment='状态:1启用0禁用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class SortingTask(Base):
    """分装任务表"""
    __tablename__ = 'sorting_task'

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_no = Column(String(64), unique=True, nullable=False, comment='任务编号')
    batch_no = Column(String(64), comment='批次号')
    sku_code = Column(String(64), comment='SKU编码')
    product_name = Column(String(256), comment='品名')
    total_qty = Column(Integer, default=0, comment='总数量')
    completed_qty = Column(Integer, default=0, comment='已完成数量')
    target_point_id = Column(Integer, ForeignKey('pickup_point.id'), comment='目标收件点')
    priority = Column(Integer, default=0, comment='优先级:0普通1高2紧急')
    assignee = Column(String(64), comment='分装人员')
    status = Column(Integer, default=0, comment='状态:0待分配1分装中2已完成3异常')
    remark = Column(Text, comment='备注')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
