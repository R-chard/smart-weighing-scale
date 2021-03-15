const functions = require('firebase-functions');
const admin = require('firebase-admin');

let sent_payload_normal;
let sent_payload_dire;
let parentName;

admin.initializeApp(functions.config().functions);

exports.messageTrigger = functions.database.ref('/UserData/{userkeys}').onUpdate((change) => {
    // triggered when there is a change to any values in any key in the userData db
    // Because it is onUpdate, the rest of the values would not trigger upon creation 
    // (Currenlty no options to change the other values other than typing)
    
    var after = change.after.val();
    var before = change.before.val();

    if (parentName === null || change.after.ref !== parentName){
        // resets the notif disabler if u change user
        parentName = change.after.ref;
        sent_payload_dire = false;
        sent_payload_normal = false;
    }

    var afterWeight = after["PWeight"];
    var beforeWeight = before["PWeight"];
    // const timeEdited = Date.now();

    const tokens = [
        "cMSkPOwGOvo:APA91bHTcMZD0cCOSGhGX9S8SQXTW8ToHFGC7fhCiWreBJ5WySv42_hBVXfIlvan96Yjxk6TEK6vyZLKqWa3KgiT6XU5bQGWn3odbsG7TpwO8NcU-iiQ3OhyDsaYTO62AsqutkPHcSTU"
    ];  // tokenID of my phone

    const payload_normal = {
        notification: {title: 'Smart Weighing Scale', body: "One of your client's fuel level has dropped below optimal level", sound: 'default'},
        data : {click_action: 'FLUTTER_NOTIFICATION_CLICK', name: after["Name"], 
                address: after["Address"], hp: after["HP"].toString(), pweight: after["PWeight"]}
    };

    const payload_dire = {
        notification: {title: 'Smart Weighing Scale', body: "One of your client needs a refill quickly", sound: 'default'},
        data : {click_action: 'FLUTTER_NOTIFICATION_CLICK', name: after["Name"], 
                address: after["Address"], hp: after["HP"].toString(), pweight: after["PWeight"]}
    } 

    if (!isNaN(afterWeight) && !isNaN(beforeWeight)){
        // Numbers return false
        afterWeight = parseInt(afterWeight);
        beforeWeight = parseInt(beforeWeight);
        
        if(afterWeight > 80){
            // assumes top up if above 80% full
            sent_payload_normal = false;
            sent_payload_dire = false;
        }

        if ((afterWeight <= 50) && (afterWeight < beforeWeight) && (!sent_payload_normal)){
            // prevents spam
            sent_payload_normal = true;
            return admin.messaging().sendToDevice(tokens,payload_normal);
        } 
        else if ((afterWeight <= 20) && (afterWeight < beforeWeight) && (!sent_payload_dire)){
            sent_payload_dire = true;
            return admin.messaging().sendToDevice(tokens,payload_dire);
        } 
    }

    return null;
    
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
