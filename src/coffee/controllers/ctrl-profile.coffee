app = angular.module 'materia'
app.controller 'profileCtrl', ['$scope', 'userServ', ($scope, userServ) ->
	$scope.more = false
	$scope.loading = false
	_offset = 0

	$scope.user = userServ.getCurrentUser()
	$scope.avatar = userServ.getCurrentUserAvatar(100)

	# Executes the API function and an optional callback function
	# @param   callback	optional callback
	$scope.getLogs = (callback) ->
		$scope.loading = true

		#Gets current user
		Materia.Coms.Json.send 'play_activity_get', [_offset], (data) ->
			_showPlayActivity data
			callback() if callback?

	# Shows selected game information on the mainscreen.
	# @param   data   Score data sent back from the server
	_showPlayActivity = (data) ->
		if !$scope.activities
			$scope.activities = []
		$scope.activities.push.apply($scope.activities, data.activity)
		$scope.more = data.more
		_offset = $scope.activities.length
		$scope.loading = false
		$scope.$apply()

	$scope.getLink = (activity) ->
		if activity.is_complete == '1'
			return '/scores/' + activity.inst_id + '#play-' + activity.play_id
		return ''

	$scope.getScore = (activity) ->
		if activity.is_complete == '1'
			return Math.round(parseFloat(activity.percent))
		return '--'

	$scope.getStatus = (activity) ->
		if activity.is_complete == '1'
			return ''
		return 'No Score Recorded'

	$scope.getDate = (activity) ->
		Materia.Set.DateTime.parseObjectToDateString(activity.created_at) +
		' at ' +
		Materia.Set.DateTime.fixTime(parseInt(activity.created_at, 10)*1000, DATE)

	Namespace('Materia.Profile.Activity').Load =
		init: -> #noop empty function
		getLogs: $scope.getLogs
	$("#activity_grid_noscores").hide()

	$(".profile h3").addClass('loading')

	Materia.Profile.Activity.Load.init(API_LINK)

	Materia.Profile.Activity.Load.getLogs ->
		$(".profile h3").removeClass('loading')

]

