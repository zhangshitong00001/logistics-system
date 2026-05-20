from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.alert import AlertRecord, AlertRule
from datetime import datetime, timezone

router = APIRouter(prefix="/api/v1/alert", tags=["异常预警中心"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """预警仪表盘"""
    today_new = db.query(func.count(AlertRecord.id)).filter(
        func.date(AlertRecord.create_time) == func.current_date(),
    ).scalar() or 0

    pending = db.query(func.count(AlertRecord.id)).filter(
        AlertRecord.status == 0,
    ).scalar() or 0

    overdue = db.query(func.count(AlertRecord.id)).filter(
        AlertRecord.status == 0,
        AlertRecord.create_time < func.now() - func.make_interval(hours=24),
    ).scalar() or 0

    total_week = db.query(func.count(AlertRecord.id)).filter(
        AlertRecord.create_time >= func.now() - func.make_interval(days=7),
    ).scalar() or 0

    resolved = db.query(func.count(AlertRecord.id)).filter(
        AlertRecord.status == 2,
        AlertRecord.create_time >= func.now() - func.make_interval(days=7),
    ).scalar() or 0

    avg_handle = db.query(func.avg(
        func.extract('epoch', AlertRecord.handle_time - AlertRecord.create_time) / 3600
    )).filter(
        AlertRecord.status == 2,
        AlertRecord.handle_time.isnot(None),
    ).scalar() or 0

    return {
        "code": 200,
        "data": {
            "today_new": today_new, "pending": pending,
            "overdue": overdue, "total_week": total_week,
            "resolved": resolved, "avg_handle_hours": round(float(avg_handle), 1),
        }
    }


@router.get("/record")
def get_records(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    alert_type: str = "",
    severity: str = "",
    status: int = -1,
    db: Session = Depends(get_db),
):
    """预警记录列表"""
    q = db.query(AlertRecord)
    if alert_type:
        q = q.filter(AlertRecord.alert_type == alert_type)
    if severity:
        q = q.filter(AlertRecord.severity == severity)
    if status >= 0:
        q = q.filter(AlertRecord.status == status)

    total = q.count()
    records = q.order_by(AlertRecord.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "batch_no": r.batch_no,
                "alert_type": r.alert_type, "severity": r.severity,
                "content": r.content[:200] if r.content else "",
                "status": r.status,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.put("/record/{record_id}/handle")
def handle_alert(record_id: int, handle_result: str = "", db: Session = Depends(get_db)):
    """处理预警"""
    record = db.query(AlertRecord).filter(AlertRecord.id == record_id).first()
    if not record:
        return {"code": 404, "message": "预警记录不存在"}
    record.status = 2
    record.handle_result = handle_result
    record.handle_time = datetime.now(timezone.utc)
    db.commit()
    return {"code": 200, "message": "处理完成"}


@router.get("/rule")
def get_rules(page: int = Query(1, ge=1), size: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    """预警规则列表"""
    q = db.query(AlertRule).filter(AlertRule.deleted == 0)
    total = q.count()
    records = q.order_by(AlertRule.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()
    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "rule_name": r.rule_name, "alert_type": r.alert_type,
                "severity": r.severity, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.put("/rule/{rule_id}")
def update_rule(rule_id: int, status: int = 1, db: Session = Depends(get_db)):
    """更新预警规则"""
    rule = db.query(AlertRule).filter(AlertRule.id == rule_id, AlertRule.deleted == 0).first()
    if not rule:
        return {"code": 404, "message": "规则不存在"}
    rule.status = status
    db.commit()
    return {"code": 200, "message": "更新成功"}
