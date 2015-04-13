class PetitionsController < ApplicationController
  before_action :set_petition, only: [:show, :edit, :update, :destroy]

  # GET /petitions
  # GET /petitions.json
  def index
    @page = params[:page]
    order = params[:order] || 0 
    @sorting = params[:sort]

    petitions = Petition  

    # enable search on petition title. TODO ransack?
    @search = 0
    if params[:search]
      petitions = Petition.findbyname(params[:search])
      @search = params[:search]
    end

    # enable sorting..
    if @sorting then
        direction = [:desc, :asc][order.to_i] 
        if @sorting == 'name' then
          petitions = petitions.order(name: direction)
        else 
          petitions = petitions.order(signatures_count: direction)
        end
    end


    
    @petitions = petitions.paginate(:page => params[:page])
    @order = order == '1'? 0 : 1 

  end

  # GET /petitions/1
  # GET /petitions/1.json
  def show
    @signatures = @petition.signatures.paginate(:page => params[:page])
    @prominenten = @signatures
  end

  # GET /petitions/new
  def new
    @petition = Petition.new
  end

  # GET /petitions/1/edit
  def edit
  end

  # POST /petitions
  # POST /petitions.json
  def create
    @petition = Petition.new(petition_params)

    respond_to do |format|
      if @petition.save
        format.html { redirect_to @petition, :flash => {:success => t('petition.created')} }
        format.json { render :show, status: :created, location: @petition }
      else
        format.html { render :new }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /petitions/1
  # PATCH/PUT /petitions/1.json
  def update
    respond_to do |format|
      if @petition.update(petition_params)
        format.html { redirect_to @petition, :flash => {:success => 'Petition was successfully updated.' }}
        format.json { render :show, status: :ok, location: @petition }
      else
        format.html { render :edit }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /petitions/1
  # DELETE /petitions/1.json
  def destroy
    @petition.destroy
    respond_to do |format|
      format.html { redirect_to petitions_url, notice: 'Petition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_petition
      @petition = Petition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def petition_params
      params.require(:petition).permit(
          :name, :description, :request, :petitioner_email, :password)
    end
end
