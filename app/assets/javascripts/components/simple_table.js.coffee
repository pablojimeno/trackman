R = React.DOM

module.exports = React.createClass

	render: ->
		window.children = @props.children
		React.createElement Table, {className: 'simple_table mi-size', style: {borderBottom: '1px solid #eee'}, striped: true, condensed: true, responsive: true, hover: true},
			R.thead null,
				R.tr null,
					R.th null, col for col in @props.columns
			R.tbody null,
				@props.children
