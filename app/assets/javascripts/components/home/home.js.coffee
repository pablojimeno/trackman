R = React.DOM
IntervalMixin = require('../utils/interval_mixin')
LogBook = require('./log_book')
CarsOverview = require('./cars_overview')
Map = require('./map')
Reflux = require('reflux');
Actions = require('../utils/actions')
CarStore = require('../stores/cars-store')
ReactInterval = require('react-interval')

module.exports = React.createClass

  mixins: [
    IntervalMixin,
    Reflux.listenTo CarStore, "onCarsStoreChange"
  ]

  getInitialState: ->
    {cars: [], active_cars: []}

  fetchData: ->
    Actions.getCars(@props.carsOverviewPath)
    # self = @
    # window.setTimeout ->
    #   self.fetchData()
    # , 5000

  componentWillMount: ->
    @fetchData()

  onCarsStoreChange: (event, cars) ->
    @setState cars: cars
    @setState active_cars: $.grep @state.cars, (e) ->
      e.last_seen != "-"

  render: ->
    R.div null,
      R.div className: "row",
        R.div className: "col-md-12 top-analyze-view", style: {position: "relative"},
          # Map
          R.div {className: "col-md-12 home-map no-padding"},
            React.createElement Map,
              carsIndexPath: @props.carsIndexPath,
              cars: @state.cars, title: "Map Overview",
              pinIcon: @props.pinIcon,
              carIcon: @props.carIcon,
              parkingIcon: @props.parkingIcon,
              emptyIcon: @props.emptyIcon,
              activeCars: @state.active_cars

          # Cars Overview
          R.div {className: "col-md- home-cars-overview", style: {position: "absolute", right: "0px", top: "0px", zIndex: "2"}},
            React.createElement CarsOverview,
            carsOverviewPath: @props.carsOverviewPath,
            cars: @state.cars,
            activeCars: @state.active_cars

      R.div className: "row",
        # Logbook
        R.div className: "col-md-12",
        React.createElement LogBook,
        carsStatisticsPath: @props.carsStatisticsPath,
        activeCars: @state.active_cars,
        cars: @state.cars
