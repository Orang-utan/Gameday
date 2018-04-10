// Copyright 2017 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

const moment = require('moment');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.minutely_job =
  functions.pubsub.topic('minutely-tick').onPublish((event) => {
    console.log("This job is ran every minute!");
    var nowStartSecond = moment().second(0).toDate();
    var nowEndSecond = moment().second(59).toDate();
    const gamePostsRef = db.collection('game_posts')
    var startedGameRef = gamePostsRef
      .where('start_date', '>=', nowStartSecond)
      .where('start_date', '<=', nowEndSecond)
      .get()
      .then(snapshot => {
        snapshot.forEach(doc => {
          // Notification details.
          const payload = {
            notification: {
              title: 'Gameday',
              body: `${doc.get('level')} ${doc.get('sport_type')} has just began! Update the score on Gameday.`
            }
          };
          console.log(payload);
          admin.messaging().sendToTopic('game_started_and_game_ended', payload);
        });
      })
      .catch(err => {
        console.log('Error getting documents', err);
      });
    return startedGameRef;
  });