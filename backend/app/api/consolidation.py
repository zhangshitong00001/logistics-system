from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.warehouse_inventory import WarehouseInventory, WarehouseReceipt

router = APIRouter(prefix="/api/v1/consolidation", tags=["云仓集货管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """集货仪表盘"""
    total_stock = db.query(func.sum(WarehouseInventory.total_qty)).filter(
        WarehouseInventory.deleted == 0
    ).scalar() or 0

    total_weight = db.query(func.sum(WarehouseInventory.weight_kg * WarehouseInventory.total_qty)).filter(
        WarehouseInventory.deleted == 0
    ).scalar() or 0

    today_receipts = db.query(func.count(WarehouseReceipt.id)).filter(
        func.date(WarehouseReceipt.create_time) == func.current_date(),
        WarehouseReceipt.deleted == 0,
    ).scalar() or 0

    low_stock = db.query(func.count(WarehouseInventory.id)).filter(
        WarehouseInventory.available_qty <= WarehouseInventory.alert_low_qty,
        WarehouseInventory.alert_low_qty > 0,
        WarehouseInventory.deleted == 0,
    ).scalar() or 0

    high_stock = db.query(func.count(WarehouseInventory.id)).filter(
        WarehouseInventory.available_qty >= WarehouseInventory.alert_high_qty,
        WarehouseInventory.alert_high_qty > 0,
        WarehouseInventory.deleted == 0,
    ).scalar() or 0

    return {
        "code": 200,
        "data": {
            "total_stock": float(total_weight),
            "total_qty": int(total_stock),
            "today_receipts": int(today_receipts),
            "low_stock_warnings": int(low_stock),
            "high_stock_warnings": int(high_stock),
        }
    }


@router.get("/inventory")
def get_inventory(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    keyword: str = "",
    db: Session = Depends(get_db),
):
    """库存明细列表"""
    q = db.query(WarehouseInventory).filter(WarehouseInventory.deleted == 0)
    if keyword:
        q = q.filter(
            WarehouseInventory.sku_code.ilike(f"%{keyword}%") |
            WarehouseInventory.product_name.ilike(f"%{keyword}%")
        )

    total = q.count()
    records = q.order_by(WarehouseInventory.update_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id,
                "sku_code": r.sku_code,
                "product_name": r.product_name,
                "category": r.category,
                "total_qty": r.total_qty,
                "available_qty": r.available_qty,
                "locked_qty": r.locked_qty,
                "weight_kg": r.weight_kg,
                "location": r.location,
                "owner": r.owner,
            } for r in records],
            "total": total,
            "page": page,
            "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/receipt")
def create_receipt(
    batch_no: str = "",
    sku_code: str = "",
    product_name: str = "",
    qty: int = 0,
    weight_kg: float = 0,
    owner: str = "",
    location: str = "",
    operator: str = "",
    db: Session = Depends(get_db),
):
    """收货登记"""
    import uuid
    receipt_no = f"RC-{func.current_date()}-{uuid.uuid4().hex[:6].upper()}"

    receipt = WarehouseReceipt(
        receipt_no=receipt_no,
        batch_no=batch_no,
        sku_code=sku_code,
        product_name=product_name,
        qty=qty,
        weight_kg=weight_kg,
        owner=owner,
        location=location,
        operator=operator,
    )
    db.add(receipt)

    # Update inventory
    inv = db.query(WarehouseInventory).filter(
        WarehouseInventory.sku_code == sku_code,
        WarehouseInventory.deleted == 0,
    ).first()

    if inv:
        inv.total_qty += qty
        inv.available_qty += qty
        inv.weight_kg = weight_kg
    else:
        inv = WarehouseInventory(
            sku_code=sku_code,
            product_name=product_name,
            total_qty=qty,
            available_qty=qty,
            weight_kg=weight_kg,
            location=location,
            owner=owner,
        )
        db.add(inv)

    db.commit()
    return {"code": 200, "message": "收货成功", "data": {"receipt_no": receipt_no}}
