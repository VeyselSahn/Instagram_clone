const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();


   exports.takipGerceklesti = functions.firestore.document('Follow Amount Stuff/{takipEdilenId}/followers/{takipEdenKullaniciId}').onCreate(async (snapshot, context) => {
       const takipEdilenId = context.params.takipEdilenId;
       const takipEdenId = context.params.takipEdenKullaniciId;

      const gonderilerSnapshot = await admin.firestore().collection("Post").doc(takipEdilenId).collection("Post List").get();

      gonderilerSnapshot.forEach((doc)=>{
           if(doc.exists){
               const gonderiId = doc.id;
               const gonderiData = doc.data();

               admin.firestore().collection("flows").doc(takipEdenId).collection("usersFlows").doc(gonderiId).set(gonderiData);
           }
      });
   });


   exports.takiptenCikildi = functions.firestore.document('Follow Amount Stuff/{takipEdilenId}/followers/{takipEdenKullaniciId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("flows").doc(takipEdenId).collection("usersFlows").where("ownerID", "==", takipEdilenId).get();

   gonderilerSnapshot.forEach((doc)=>{
        if(doc.exists){
            doc.ref.delete();
        }
   });
});

exports.yeniGonderiEklendi = functions.firestore.document('Post/{takipEdilenKullaniciId}/Post List/{gonderiId}').onCreate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const yeniGonderiData = snapshot.data();

    const takipcilerSnapshot = await admin.firestore().collection("Follow Amount Stuff").doc(takipEdilenId).collection("followers").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("flows").doc(takipciId).collection("usersFlows").doc(gonderiId).set(yeniGonderiData);
    });
});

exports.gonderiGuncellendi = functions.firestore.document('Post/{takipEdilenKullaniciId}/Post List/{gonderiId}').onUpdate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const guncellenmisGonderiData = snapshot.after.data();

    const takipcilerSnapshot = await admin.firestore().collection("Follow Amount Stuff").doc(takipEdilenId).collection("followers").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("flows").doc(takipciId).collection("usersFlows").doc(gonderiId).update(guncellenmisGonderiData);
    });
});

exports.gonderiSilindi = functions.firestore.document('Post/{takipEdilenKullaniciId}/Post List/{gonderiId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;

    const takipcilerSnapshot = await admin.firestore().collection("Follow Amount Stuff").doc(takipEdilenId).collection("followers").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("flows").doc(takipciId).collection("usersFlows").doc(gonderiId).delete();
    });
});
