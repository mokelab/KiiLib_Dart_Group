import 'package:kiilib_core/kiilib_core.dart';

abstract class GroupAPI {
  Future<KiiGroup> create(String name, KiiUser owner, List<KiiUser> members);
  Future<KiiGroup> fetch(String id);
  Future<KiiGroup> updateGroupName(KiiGroup group, String name);
  Future<bool> delete(KiiGroup group);
  Future<List<KiiGroup>> getJoinedGroups(KiiUser user);
  Future<List<KiiGroup>> getOwnedGroups(KiiUser user);
  Future<KiiGroup> addMember(KiiGroup group, KiiUser user);
  Future<KiiGroup> removeMember(KiiGroup group, KiiUser user);
  Future<List<KiiUser>> fetchMembers(KiiGroup group);
}
