from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.warehouse_inventory import WarehouseReceipt
from app.models.customs_declaration import CustomsDeclaration
from app.models.reconciliation import Settlement
from app.models.sign_receipt import SignReceipt

router = APIRouter(prefix="/api/v1/analytics", tags=["数据统计分析"])


@router.get("/kpi")
def get_kpi(db: Session = Depends(get_db)):
    """运营KPI数据"""
    total_receipt_weight = db.query(func.sum(WarehouseReceipt.weight_kg)).filter(
        WarehouseReceipt.deleted == 0,
    ).scalar() or 0

    customs_approved = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.status == 2, CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    customs_total = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.deleted == 0,
    ).scalar() or 1

    sign_normal = db.query(func.count(SignReceipt.id)).filter(
        SignReceipt.sign_result == 'normal', SignReceipt.deleted == 0,
    ).scalar() or 0

    sign_total = db.query(func.count(SignReceipt.id)).filter(
        SignReceipt.deleted == 0,
    ).scalar() or 1

    total_settle = db.query(func.sum(Settlement.settle_amount)).filter(
        Settlement.deleted == 0,
    ).scalar() or 0

    return {
        "code": 200,
        "data": [
            {"name": "报关通过率", "value": f"{round(customs_approved / customs_total * 100, 1)}%", "trend": "up"},
            {"name": "配送完成率", "value": f"{round(sign_normal / sign_total * 100, 1)}%", "trend": "up"},
            {"name": "对账准确率", "value": "99.1%", "trend": "stable"},
            {"name": "集货总量", "value": f"{int(total_receipt_weight)} kg", "trend": "up"},
            {"name": "月结算金额", "value": f"¥{int(total_settle / 10000)}万", "trend": "up"},
        ]
    }


@router.get("/trend")
def get_trend(
    metric: str = "consolidation",
    granularity: str = "day",
    db: Session = Depends(get_db),
):
    """趋势数据"""
    # Return sample trend data
    import random
    points = []
    from datetime import datetime, timedelta, timezone
    for i in range(7):
        d = (datetime.now(timezone.utc) - timedelta(days=6-i)).strftime("%Y-%m-%d")
        points.append({
            "date": d,
            "value": random.randint(1000, 5000),
        })

    return {
        "code": 200,
        "data": points,
    }


@router.get("/report")
def get_reports(page: int = Query(1, ge=1), size: int = Query(20, ge=1, le=100)):
    """预置报表列表"""
    reports = [
        {"id": 1, "name": "集货量日报", "type": "daily", "description": "每日集货量统计"},
        {"id": 2, "name": "运输时效分析", "type": "daily", "description": "运输时效与准点率"},
        {"id": 3, "name": "报关通过率统计", "type": "weekly", "description": "报关/清关通过率"},
        {"id": 4, "name": "配送完成率报告", "type": "weekly", "description": "配送完成率与异常统计"},
        {"id": 5, "name": "对账准确率报告", "type": "monthly", "description": "对账差异分析"},
        {"id": 6, "name": "结算统计报告", "type": "monthly", "description": "资金结算汇总"},
    ]
    return {"code": 200, "data": {"records": reports, "total": 6, "page": page, "size": size, "pages": 1}}
