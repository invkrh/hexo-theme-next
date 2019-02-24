{% if theme.firestore.enable %}
  <script src="https://www.gstatic.com/firebasejs/5.8.1/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/5.8.1/firebase-firestore.js"></script>
  <script src="https://www.gstatic.com/firebasejs/5.8.1/firebase-auth.js"></script>
  <script>
    (function () {
      function getCount(docRef) {
        return docRef.get().then(function (doc) {
          if (!doc.exists) {
            return 0;
          } else {
            return doc.data().count;
          }
        });
      }

      // TODO: use distributed counter
      function increaseCount(docRef, firstViewOnly) {
        return function (prevCount) {
          if (firstViewOnly && window.localStorage) {
            // increase view count if the article is viewed for the first time
            // increase view count in case the doc is removed
            if (!window.localStorage.getItem('{{ page.title }}') || prevCount == 0) {
              docRef.set({ count: prevCount + 1 })
              .then(function() {
                localStorage.setItem('{{ page.title }}', true);
              })
              .catch(function(error) {
                console.error("Error writing document: ", error);
              });
            }
          } else {
            docRef.set({ count: prevCount + 1 });
          }
        }
      }

      function appendCount2PostMeta(el) {
        return function (count) {
          $(el)
            .append(
              $('<span>')
                .addClass('post-visitors-count')
                .append(
                  $('<span>')
                    .addClass('post-meta-divider')
                    .text('|'))
                .append(
                  $('<span>')
                    .addClass('post-meta-item-icon')
                    .append(
                      $('<i>')
                      .addClass('fa fa-eye')))
                .append(
                  $('<span>')
                  .text('{{ __('post.views') }} ' + count)));
        }
      }

      function countRead() {
        // See: https://hexo.io/docs/helpers.html
        if ({{ is_post() }}) { //is article page
          var docRef = articles.doc('{{ page.title }}')
          getCount(docRef)
            .then(increaseCount(docRef, true))
            .then(function() { return getCount(docRef) })
            .then(appendCount2PostMeta($('.post-meta'))); // only one post-meta class for post page
        } else if ({{ is_home() }}) { //is index page
          var titles = []; //array to titles

          {% for post in page.posts %}
            titles.push('{{ post.title }}');
          {% endfor %}

          var promises = titles.map(function (title) {
            return articles.doc(title);
          }).map(function (docRef) {
            return getCount(docRef);
          })

          Promise.all(promises).then(function (counts) {
            var metas = $('.post-meta'); // all the post-meta classes for current index page
            counts.forEach(function (val, idx) {
              appendCount2PostMeta(metas[idx])(val);
            })
          })
        }
      }

      var config = {
        apiKey: '{{ theme.firestore.apiKey }}',
        authDomain: '{{ theme.firestore.authDomain }}',
        projectId: '{{ theme.firestore.projectId }}'
      };

      firebase.initializeApp(config);

      var db = firebase.firestore();

      var articles = db.collection('{{ theme.firestore.collection }}');

      firebase.auth().signInAnonymously().catch(function(error) {
        // Handle Errors here.
        var errorCode = error.code;
        var errorMessage = error.message;
        console.log(errorCode);
        console.log(errorMessage);
      });

      /*
      Only anonymous user of authorized domain sign in.
      Incease the counter for signed anonymous users.
      ===>
      Only request from authorized domain can increase counter.
      */

      firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
          // User is signed in.
          var isAnonymous = user.isAnonymous;
          var uid = user.uid;
          countRead();
        } else {
          // User is signed out.
          // ...
        }
      });
    })()
  </script>
{% endif %}
