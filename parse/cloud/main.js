Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("authorizePusherChannel", function(request, response) {

	var Pusher = require('cloud/pusher.js');

	var pusher = new Pusher({
	  appId: '70195',
	  key: '3d525a02ba7dca6d31ad',
	  secret: '6ba6a17c9c8f515eb78c'
	});
	console.log(request.params["socket_id"]);
	console.log(request.params["channel_name"]);

	var auth = pusher.auth(request.params["socket_id"],request.params["channel_name"]);
   console.log(auth);
   response.success(auth);
});

Parse.Cloud.define("authorizePusherPresenceChannel", function(request, response) {
var Pusher = require('cloud/pusher.js');

	var pusher = new Pusher({
	  appId: '70194',
	  key: '3d525a02ba7dca6d31ad',
	  secret: '642a263c324110293bf0'
	});

	var user = Parse.User.current();
	var channelData = {
	    user_id: user.id,
	    user_info: {
	      userName : user.getUsername(),
	      email: user.getEmail(),
	    }
	};

	var auth = pusher.auth( request.params["socket_id"], request.params["channel_name"], channelData);
    console.log(auth);
	response.success(auth);
});

