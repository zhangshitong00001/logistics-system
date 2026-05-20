from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.billing_rule import BillingRule

router = APIRouter(prefix="/api/v1/billing", tags=["计费规则配置"])


@router.get("/rules")
def get_rules(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    fee_type: str = "",
    db: Session = Depends(get_db),
):
    """计费规则列表"""
    q = db.query(BillingRule).filter(BillingRule.deleted == 0)
    if fee_type:
        q = q.filter(BillingRule.fee_type == fee_type)

    total = q.count()
    records = q.order_by(BillingRule.priority.asc()).offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "rule_name": r.rule_name, "fee_type": r.fee_type,
                "charge_method": r.charge_method,
                "base_rate": float(r.base_rate) if r.base_rate else 0,
                "rate_unit": r.rate_unit, "currency": r.currency,
                "priority": r.priority, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/rules")
def create_rule(
    rule_name: str = "", fee_type: str = "transport",
    charge_method: str = "weight", base_rate: float = 0,
    rate_unit: str = "元/kg", currency: str = "CNY",
    priority: int = 0,
    db: Session = Depends(get_db),
):
    """创建计费规则"""
    rule = BillingRule(
        rule_name=rule_name, fee_type=fee_type,
        charge_method=charge_method, base_rate=base_rate,
        rate_unit=rate_unit, currency=currency,
        priority=priority,
    )
    db.add(rule)
    db.commit()
    return {"code": 200, "data": {"rule_id": rule.id}}


@router.put("/rules/{rule_id}")
def update_rule(
    rule_id: int, base_rate: float = None,
    status: int = None,
    db: Session = Depends(get_db),
):
    """更新计费规则"""
    rule = db.query(BillingRule).filter(BillingRule.id == rule_id, BillingRule.deleted == 0).first()
    if not rule:
        return {"code": 404, "message": "规则不存在"}
    if base_rate is not None:
        rule.base_rate = base_rate
    if status is not None:
        rule.status = status
    db.commit()
    return {"code": 200, "message": "更新成功"}


@router.post("/rules/{rule_id}/surcharge")
def add_surcharge(rule_id: int, surcharge_name: str = "", rate: float = 0, db: Session = Depends(get_db)):
    """新增附加费（作为关联的子规则）"""
    rule = db.query(BillingRule).filter(BillingRule.id == rule_id, BillingRule.deleted == 0).first()
    if not rule:
        return {"code": 404, "message": "规则不存在"}
    # Create as a sibling rule
    sub = BillingRule(
        rule_name=surcharge_name, fee_type="surcharge",
        charge_method="fixed", base_rate=rate,
        currency=rule.currency, priority=rule.priority + 1,
    )
    db.add(sub)
    db.commit()
    return {"code": 200, "data": {"surcharge_id": sub.id}}
