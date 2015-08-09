class CoreResourcesController < ApiController
  def index
    @growers = Grower.all
    @farms = Farm.all
    @fields = Field.all
    @plantings = Planting.all

    render json: {
      core_resources: [
        growers: @growers,
        farms: @farms,
        fields: @fields,
        plantings: @plantings
      ]
    }
  end
end
