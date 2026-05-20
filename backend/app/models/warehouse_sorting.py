from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class WarehouseSortingTask(Base):
    """仓库分拣任务表"""
    __tablename__ = 'warehouse_sorting_task'

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_no = Column(String(64), unique=True, nullable=False, comment='任务编号')
    batch_no = Column(String(64), comment='批次号')
    sku_code = Column(String(64), comment='SKU编码')
    product_name = Column(String(256), comment='品名')
    total_qty = Column(Integer, default=0, comment='总数量')
    sorted_qty = Column(Integer, default=0, comment='已分拣数量')
    location = Column(String(64), comment='库位')
    assignee = Column(String(64), comment='分拣员')
    status = Column(Integer, default=0, comment='状态:0待分拣1分拣中2已完成3异常')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
