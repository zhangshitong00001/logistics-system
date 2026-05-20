# 导入所有模型确保 Base.metadata.create_all() 发现所有表
from app.models.sys_user import SysUser
from app.models.sys_role import SysRole
from app.models.sys_permission import SysPermission
from app.models.sys_role_permission import SysRolePermission
from app.models.sys_operation_log import SysOperationLog
from app.models.warehouse_inventory import WarehouseInventory, WarehouseReceipt
from app.models.sorting import PickupPoint, SortingTask
from app.models.file_record import FileRecord, FileTemplate
from app.models.transport import TransportVehicle, TransportTask
from app.models.customs_declaration import CustomsDeclaration
from app.models.warehouse_sorting import WarehouseSortingTask
from app.models.delivery import DeliveryTask
from app.models.sign_receipt import SignReceipt
from app.models.tracking import TrackingPackage, TrackingLog
from app.models.reconciliation import Reconciliation, Settlement
from app.models.payment import Payment, Invoice
from app.models.alert import AlertRule, AlertRecord
from app.models.billing_rule import BillingRule

from app.core.database import Base

__all__ = [
    "Base",
    "SysUser", "SysRole", "SysPermission", "SysRolePermission", "SysOperationLog",
    "WarehouseInventory", "WarehouseReceipt",
    "PickupPoint", "SortingTask",
    "FileRecord", "FileTemplate",
    "TransportVehicle", "TransportTask",
    "CustomsDeclaration",
    "WarehouseSortingTask",
    "DeliveryTask",
    "SignReceipt",
    "TrackingPackage", "TrackingLog",
    "Reconciliation", "Settlement",
    "Payment", "Invoice",
    "AlertRule", "AlertRecord",
    "BillingRule",
]
