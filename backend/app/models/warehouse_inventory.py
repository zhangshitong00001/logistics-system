from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class WarehouseInventory(Base):
    """云仓库存表"""
    __tablename__ = 'warehouse_inventory'

    id = Column(Integer, primary_key=True, autoincrement=True)
    sku_code = Column(String(64), unique=True, nullable=False, comment='SKU编码')
    product_name = Column(String(256), nullable=False, comment='品名')
    category = Column(String(64), comment='品类')
    weight_kg = Column(Float, default=0, comment='单位重量(kg)')
    total_qty = Column(Integer, default=0, comment='总库存')
    available_qty = Column(Integer, default=0, comment='可用数量')
    locked_qty = Column(Integer, default=0, comment='锁定数量')
    location = Column(String(64), comment='库位')
    owner = Column(String(128), comment='货主')
    alert_low_qty = Column(Integer, default=0, comment='缺货预警阈值')
    alert_high_qty = Column(Integer, default=0, comment='溢货预警阈值')
    status = Column(Integer, default=1, comment='状态:1正常0停用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class WarehouseReceipt(Base):
    """收货记录表"""
    __tablename__ = 'warehouse_receipt'

    id = Column(Integer, primary_key=True, autoincrement=True)
    receipt_no = Column(String(64), unique=True, nullable=False, comment='收货单号')
    batch_no = Column(String(64), nullable=False, comment='批次号')
    sku_code = Column(String(64), nullable=False, comment='SKU编码')
    product_name = Column(String(256), comment='品名')
    qty = Column(Integer, nullable=False, comment='数量')
    weight_kg = Column(Float, default=0, comment='重量(kg)')
    owner = Column(String(128), comment='货主')
    location = Column(String(64), comment='存放库位')
    operator = Column(String(64), comment='操作人')
    receipt_date = Column(DateTime, comment='收货日期')
    status = Column(Integer, default=0, comment='状态:0待确认1已确认')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
