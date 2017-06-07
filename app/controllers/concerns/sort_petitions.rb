require 'active_support/concern'

module SortPetitions
  extend ActiveSupport::Concern

  def sort_petitions(petitions)
    @page    = cleanup_page(params[:page])
    @sorting = params[:sorting] || 'all'
    @order   = params[:order].to_i

    # describe petitions
    case @sorting
    when 'all'
      petitions = petitions.where("status NOT IN ('concept', 'staging')").order(created_at: :desc).limit(100)
    when 'open'
      petitions = petitions.live.order(created_at: :desc).limit(100)
    when 'concluded'
      petitions = petitions.where(status: 'completed').order(created_at: :desc).limit(100)
    when 'rejected'
      petitions = petitions.where(status: 'rejected').order(created_at: :desc).limit(100)
    when 'sign_elsewhere'
      petitions = petitions.where(status: 'not_signable_here').order(created_at: :desc).limit(100)
    when 'answered'
      petitions = petitions.answered
    else
      direction = [:desc, :asc][@order]
      petitions = petitions.live.order(created_at: direction).limit(100)
    end

    @sorting_options = [
      { type: 'all', label: t('all.sort.all') },
      { type: 'open',           label: t('all.sort.open') },
      { type: 'concluded',      label: t('all.sort.concluded') },
      { type: 'answered',       label: t('all.sort.answered') },
      { type: 'rejected',       label: t('all.sort.rejected') },
      { type: 'sign_elsewhere', label: t('all.sort.sign_elsewhere') }
    ]

    petitions.page(@page).per(12)
  end

  def petitions_by_status(petitions)
    petitions = petitions.order(created_at: :desc).limit(20)
    # find petition in state of allow
    @petitions_draft = petitions.where(status: 'concept')
    # find petitions in state of answer
    @petitions_moderate = petitions.where(status: 'staging')
    # find petition in state of signable
    @petitions_live = petitions.live
    # find petition in state of answered
    @petitions_inproces = petitions.where("status IN ('to_process', 'in_process')")
    #
    @petitions_completed = petitions.where(status: 'completed')
    # find petition in state of done/ingetrokken
    @petitions_rejected = petitions.where(status: 'rejected')
    # withdrawn..
    @petitions_withdrawn = petitions.where(status: 'withdrawn')
  end
end
