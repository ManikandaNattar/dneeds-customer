import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission(Permission permission) async {
  Map<Permission, PermissionStatus> statuses = {};
  PermissionStatus _permissionStatus;
  _permissionStatus = await permission.status;
  if (_permissionStatus.isUndetermined || _permissionStatus.isDenied) {
    statuses = await [
      permission,
    ].request();
    _permissionStatus = statuses[permission];
  }
  return _permissionStatus.isGranted == true ? true : false;
}
