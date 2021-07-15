import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:instagram_project/models/Notification.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/services/StorageService.dart';

class firestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DateTime time = DateTime.now();

  Future<void> kullaniciOlustur({
    id,
    mail,
    username,
    pp = "",
  }) async {
    await _firestore.collection("users").doc(id).set({
      "username": username,
      "mail": mail,
      "pp": pp,
      "regarding": "",
      "creatingTime": time,
      "id": id
    });
  }

  Future<Person> getUser(id) async {
    DocumentSnapshot document =
        await _firestore.collection("users").doc(id).get();
    if (document.exists) {
      Person user = Person.producingDoc(document);
      return user;
    } else
      return null;
  }

  void updateUser(
      {String id, String username, String regarding, String url = ""}) {
    _firestore.collection("users").doc(id).update(
        {"id": id, "username": username, "regarding": regarding, "pp": url});
  }

  Future<int> getfollowers(userID) async {
    QuerySnapshot snap = await _firestore
        .collection("Follow Amount Stuff")
        .doc(userID)
        .collection("followers")
        .get();
    return snap.docs.length;
  }

  Future<int> getfollowings(userID) async {
    QuerySnapshot snap = await _firestore
        .collection("Following Amount")
        .doc(userID)
        .collection("are following")
        .get();
    return snap.docs.length;
  }

  Future<void> createPost({url, id, expla, location}) async {
    await _firestore.collection("Post").doc(id).collection("Post List").add({
      "url": url,
      "ownerID": id,
      "explanation": expla,
      "location": location,
      "likeA": 0,
      "creatingTime": time
    });
  }

  Future<List<Post>> getPosts(userID) async {
    QuerySnapshot posts = await _firestore
        .collection("Post")
        .doc(userID)
        .collection("Post List")
        .orderBy("creatingTime", descending: true)
        .get();

    List<Post> list = posts.docs.map((e) => Post.producingDoc(e)).toList();
    return list;
  }

  Future<List<Post>> getFlowPosts(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("flows")
        .doc(kullaniciId)
        .collection("usersFlows")
        .orderBy("creatingTime", descending: true)
        .get();
    List<Post> gonderiler =
        snapshot.docs.map((doc) => Post.producingDoc(doc)).toList();
    return gonderiler;
  }

  Future<void> likewithFirebase(Post post, String activeUserId) async {
    DocumentReference doct = _firestore
        .collection("Post")
        .doc(post.ownerID)
        .collection("Post List")
        .doc(post.id);

    DocumentSnapshot doc = await doct.get();

    if (doc.exists) {
      Post p = Post.producingDoc(doc);
      int newAmount = p.likeA + 1;
      doct.update({"likeA": newAmount});
    }
    _firestore
        .collection("Likes")
        .doc(post.id)
        .collection("Likers")
        .doc(activeUserId)
        .set({});

    addNotification(
        typeActivity: "like",
        post: post,
        didWho: activeUserId,
        ownerID: post.ownerID);
  }

  Future<void> dislikewithFirebase(Post post, String activeUserId) async {
    DocumentReference doct = _firestore
        .collection("Post")
        .doc(post.ownerID)
        .collection("Post List")
        .doc(post.id);

    DocumentSnapshot doc = await doct.get();

    if (doc.exists) {
      Post p = Post.producingDoc(doc);
      int newAmount = p.likeA - 1;
      doct.update({"likeA": newAmount});
    }

    DocumentSnapshot documentReference = await _firestore
        .collection("Likes")
        .doc(post.id)
        .collection("Likers")
        .doc(activeUserId)
        .get();

    if (documentReference.exists) {
      documentReference.reference.delete();
    }
  }

  Future<bool> isLiked(Post post, String activeUserId) async {
    DocumentSnapshot dct = await _firestore
        .collection("Likes")
        .doc(post.id)
        .collection("Likers")
        .doc(activeUserId)
        .get();

    if (dct.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> getComments(String postID) {
    return _firestore
        .collection("Comment")
        .doc(postID)
        .collection("Comments")
        .orderBy("time", descending: true)
        .snapshots();
  }

  addComment({String ownerID, String content, Post post}) {
    _firestore
        .collection("Comment")
        .doc(post.id)
        .collection("Comments")
        .add({"content": content, "ownerID": ownerID, "time": time});

    addNotification(
        post: post,
        typeActivity: "comment",
        ownerID: post.ownerID,
        comment: content,
        didWho: ownerID);
  }

  Future<List<Person>> searchUser(String search) async {
    QuerySnapshot snap = await _firestore
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: search)
        .get();
    List<Person> list = snap.docs.map((e) => Person.producingDoc(e)).toList();
    return list;
  }

  void follow({String ownerID, String otherID}) async {
    await _firestore
        .collection("Follow Amount Stuff")
        .doc(otherID)
        .collection("followers")
        .doc(ownerID)
        .set({});

    await _firestore
        .collection("Following Amount")
        .doc(ownerID)
        .collection("are following")
        .doc(otherID)
        .set({});

    addNotification(
      ownerID: ownerID,
      didWho: otherID,
      typeActivity: "following",
    );
  }

  void unfollow({String ownerID, String otherID}) async {
    await _firestore
        .collection("Follow Amount Stuff")
        .doc(otherID)
        .collection("followers")
        .doc(ownerID)
        .get()
        .then((value) => value.reference.delete());

    await _firestore
        .collection("Following Amount")
        .doc(ownerID)
        .collection("are following")
        .doc(otherID)
        .get()
        .then((value) => value.reference.delete());
  }

  Future<bool> controlFollow({String ownerID, String otherID}) async {
    DocumentSnapshot doct = await _firestore
        .collection("Following Amount")
        .doc(ownerID)
        .collection("are following")
        .doc(otherID)
        .get();
    if (doct.exists) {
      return true;
    }
    return false;
  }

  void addNotification(
      {String ownerID,
      String didWho,
      String typeActivity,
      Post post,
      String comment}) {
    if (ownerID == didWho) {
      return;
    }
    _firestore
        .collection("Notifications")
        .doc(ownerID)
        .collection("Notfs")
        .add({
      "postUrL": post?.url,
      "didWho": didWho,
      "postID": post?.id,
      "comment": comment,
      "typeActivity": typeActivity,
      "time": time
    });
  }

  Future<List<Duyuru>> getNotfs(String ownerID) async {
    QuerySnapshot doct = await _firestore
        .collection("Notifications")
        .doc(ownerID)
        .collection("Notfs")
        .orderBy("time", descending: true)
        .limit(10)
        .get();
    List<Duyuru> notfs = [];

    doct.docs.forEach((DocumentSnapshot documentSnapshot) {
      Duyuru duyuru = Duyuru.producingDoc(documentSnapshot);
      notfs.add(duyuru);
    });
    return notfs;
  }

  Future<Post> getPost({String postId, String userID}) async {
    DocumentSnapshot doct = await _firestore
        .collection("Post")
        .doc(userID)
        .collection("Post List")
        .doc(postId)
        .get();
    if (doct.exists) {
      Post post = Post.producingDoc(doct);
      return post;
    } else
      return null;
  }

  Future<void> deletePost({String userID, Post post}) async {
    await _firestore
        .collection("Post")
        .doc(userID)
        .collection("Post List")
        .doc(post.id)
        .get()
        .then((post) => post.reference.delete());

    QuerySnapshot snapshot = await _firestore
        .collection("Comment")
        .doc(post.id)
        .collection("Comments")
        .get();
    snapshot.docs.forEach((element) {
      if (element.exists) element.reference.delete();
    });

    QuerySnapshot querySnapshot = await _firestore
        .collection("Notifications")
        .doc(post.ownerID)
        .collection("Notfs")
        .where("postID", isEqualTo: post.id)
        .get();

    querySnapshot.docs.forEach((q) {
      if (q.exists) q.reference.delete();
    });

    StorageService().deletePost(post.url);
  }
}
