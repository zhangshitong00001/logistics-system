from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.tracking import TrackingPackage, TrackingLog

router = APIRouter(prefix="/api/v1/tracking", tags=["物流追踪"])


@router.get("/query")
def query_tracking(
    query_type: str = "order_no",
    query_value: str = "",
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """多维度查询物流状态"""
    q = db.query(TrackingPackage).filter(TrackingPackage.deleted == 0)

    if query_value:
        if query_type == "order_no":
            q = q.filter(TrackingPackage.order_no.ilike(f"%{query_value}%"))
        elif query_type == "package_no":
            q = q.filter(TrackingPackage.package_no.ilike(f"%{query_value}%"))
        elif query_type == "batch_no":
            q = q.filter(TrackingPackage.batch_no == query_value)

    total = q.count()
    records = q.order_by(TrackingPackage.update_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "package_no": r.package_no, "order_no": r.order_no,
                "batch_no": r.batch_no, "product_name": r.product_name,
                "sender": r.sender, "receiver": r.receiver,
                "current_node": r.current_node, "current_status": r.current_status,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.get("/{package_no}/detail")
def get_tracking_detail(package_no: str, db: Session = Depends(get_db)):
    """包裹物流详情"""
    pkg = db.query(TrackingPackage).filter(
        TrackingPackage.package_no == package_no, TrackingPackage.deleted == 0,
    ).first()

    if not pkg:
        return {"code": 404, "message": "包裹不存在"}

    logs = db.query(TrackingLog).filter(
        TrackingLog.package_no == package_no,
    ).order_by(TrackingLog.node_order).all()

    status_map = {
        0: "待集货", 1: "运输中", 2: "报关中",
        3: "清关中", 4: "配送中", 5: "已签收",
    }

    steps = [
        {"key": "warehouse", "label": "📦 集货", "active": pkg.current_status >= 0},
        {"key": "transport", "label": "🚛 运输", "active": pkg.current_status >= 1},
        {"key": "customs_cn", "label": "🏛️ 出口报关", "active": pkg.current_status >= 2},
        {"key": "customs_kz", "label": "🏛️ 进口清关", "active": pkg.current_status >= 3},
        {"key": "warehouse_kz", "label": "📦 仓库分拣", "active": pkg.current_status >= 4},
        {"key": "delivery", "label": "🚴 配送", "active": pkg.current_status >= 4},
        {"key": "sign", "label": "✍️ 签收", "active": pkg.current_status >= 5},
    ]

    return {
        "code": 200,
        "data": {
            "package_info": {
                "package_no": pkg.package_no, "order_no": pkg.order_no,
                "product_name": pkg.product_name,
                "sender": pkg.sender, "receiver": pkg.receiver,
                "receiver_phone": pkg.receiver_phone,
                "receiver_address": pkg.receiver_address,
                "current_status": status_map.get(pkg.current_status, "未知"),
            },
            "steps": steps,
            "timeline": [{
                "time": str(log.operate_time) if log.operate_time else str(log.create_time),
                "node": log.node_name, "operator": log.operator,
                "location": log.location, "description": log.description,
            } for log in logs],
        }
    }
