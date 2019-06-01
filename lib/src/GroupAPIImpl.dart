import 'package:kiilib_core/src/KiiGroup.dart';

import 'package:kiilib_core/kiilib_core.dart';

import './GroupAPI.dart';

import 'dart:convert';

class GroupAPIImpl implements GroupAPI {
  final KiiContext context;

  GroupAPIImpl(this.context);

  @override
  Future<KiiGroup> create(
      String name, KiiUser owner, List<KiiUser> members) async {
    var url = "${this.context.baseURL}/apps/${this.context.appID}/groups";
    var headers = this.context.makeAuthHeader();
    headers["Content-Type"] = "application/vnd.kii.GroupCreationRequest+json";

    var memberIdList = members.map((KiiUser user) => user.id).toList();
    var body = {
      'name': name,
      'owner': owner.id,
      'members': memberIdList,
    };
    var response =
        await this.context.client.sendJson(Method.POST, url, headers, body);
    if (response.status != 201) {
      print(response.body);
      throw Exception("Error");
    }

    var bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
    var groupID = bodyJson["groupID"] as String;
    var group = KiiGroup(groupID, name, owner, members);
    return group;
  }

  @override
  Future<KiiGroup> fetch(String id) async {
    var url = "${this.context.baseURL}/apps/${this.context.appID}/groups/${id}";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendJson(Method.GET, url, headers, null);
    if (response.status != 200) {
      print(response.body);
      throw Exception("Error");
    }

    var bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
    var groupID = bodyJson["groupID"] as String;
    var name = bodyJson["name"] as String;
    var ownerID = bodyJson["owner"] as String;
    return KiiGroup(groupID, name, KiiUser(ownerID), []);
  }

  @override
  Future<KiiGroup> updateGroupName(KiiGroup group, String name) async {
    var url =
        "${this.context.baseURL}/apps/${this.context.appID}${group.path}/name";
    var headers = this.context.makeAuthHeader();
    headers["Content-Type"] = "text/plain";

    var response =
        await this.context.client.sendText(Method.PUT, url, headers, name);
    if (response.status != 204) {
      print(response.body);
      throw Exception("Error");
    }

    return KiiGroup(group.id, name, group.owner, group.members);
  }

  @override
  Future<bool> delete(KiiGroup group) async {
    var url = "${this.context.baseURL}/apps/${this.context.appID}${group.path}";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendJson(Method.DELETE, url, headers, null);
    if (response.status != 204) {
      print(response.body);
      throw Exception("Error");
    }
    return true;
  }

  @override
  Future<List<KiiGroup>> getJoinedGroups(KiiUser user) async {
    return await this._getGroups(user, "is_member");
  }

  @override
  Future<List<KiiGroup>> getOwnedGroups(KiiUser user) async {
    return await this._getGroups(user, "owner");
  }

  @override
  Future<KiiGroup> addMember(KiiGroup group, KiiUser user) async {
    var url =
        "${this.context.baseURL}/apps/${this.context.appID}${group.path}/members/${user.id}";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendText(Method.PUT, url, headers, '');
    if (response.status != 204) {
      print(response.status);
      print(response.body);
      throw Exception("Error");
    }
    group.members.add(user);
    return group;
  }

  @override
  Future<KiiGroup> removeMember(KiiGroup group, KiiUser user) async {
    var url =
        "${this.context.baseURL}/apps/${this.context.appID}${group.path}/members/${user.id}";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendText(Method.DELETE, url, headers, null);
    if (response.status != 204) {
      print(response.status);
      print(response.body);
      throw Exception("Error");
    }
    // TODO remove user from list if exists
    return group;
  }

  @override
  Future<List<KiiUser>> fetchMembers(KiiGroup group) async {
    var url =
        "${this.context.baseURL}/apps/${this.context.appID}${group.path}/members";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendText(Method.GET, url, headers, null);
    if (response.status != 200) {
      print(response.status);
      print(response.body);
      throw Exception("Error");
    }

    var bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
    var membersJsonList = bodyJson["members"] as List<dynamic>;
    return membersJsonList.map((dynamic json) {
      var item = json as Map<String, dynamic>;
      var id = item['userID'];
      return KiiUser(id);
    }).toList();
  }

  Future<List<KiiGroup>> _getGroups(KiiUser user, String query) async {
    var url =
        "${this.context.baseURL}/apps/${this.context.appID}/groups?${query}=${user.id}";
    var headers = this.context.makeAuthHeader();

    var response =
        await this.context.client.sendText(Method.GET, url, headers, null);
    if (response.status != 200) {
      print(response.status);
      print(response.body);
      throw Exception("Error");
    }

    var bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
    var groupsJsonList = bodyJson["groups"] as List<dynamic>;
    return groupsJsonList.map((dynamic json) {
      var item = json as Map<String, dynamic>;
      var id = item['groupID'];
      var name = item['name'];
      var ownerId = item['owner'];
      return KiiGroup(id, name, KiiUser(ownerId), []);
    }).toList();
  }
}
