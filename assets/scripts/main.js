$(function() {
	var socket = io.connect('http://198.199.118.204:9001');
	socket.on('connected', function (data) {
		console.log(data);
	});
	socket.on('stock::update',function(data) {
		console.log(data);
		$('#loading').remove();
		if(data) {
			var tr = $('#s_tr').html();
			var td = $('#s_td').html();
			if($('#' + data.key).length > 0) {
				var td_c = _.template(td, data);
				$('#' + data.key).children().remove();
				$('#' + data.key).append(td_c);
			}else {
				var tr_r = _.template(tr, data);
				var td_d = _.template(td, data);
				$(tr_r).append($(td_d)).appendTo($('#box'));
				
			}
		}
	});
	$('#btn_submit').bind('click', function() {
		if($.trim($('#stock_key').val()) != '') {
			$.ajax({
				url: '/add_stock',
				type: 'post',
				data: 'stock_key='+$('#stock_key').val() ,
				success: function(data) {
					console.log(data);
					$('#stock_key').val('');
					$('#stock_key').focus();
				}
			});
		}else {
			alert('Please key in stock');
		}
	});
});
