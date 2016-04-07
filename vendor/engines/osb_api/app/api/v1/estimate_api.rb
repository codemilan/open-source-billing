module V1
  class EstimateApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api

    helpers do
      def get_company_id
        current_user = @current_user
        current_user.current_company || current_user.accounts.map {|a| a.companies.pluck(:id)}.first
      end

      def filter_by_company(elem)
        if params[:company_id].blank?
          company_id = get_company_id
        else
          company_id = params[:company_id]
        end
        elem.where("company_id IN(?)", company_id)
      end
    end

    resource :estimates do
      before  {current_user}

      desc 'Return users estimates'
      get do
        params[:status] = params[:status] || 'active'
        @estimates = Expense.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ")
        @estimates = filter_by_company(@estimates)
      end

      desc 'Fetch single estimates'
      params do
        requires :id, type: String
      end

      get ':id' do
        Expense.find params[:id]
      end

      desc 'Create Estimate'
      params do
        requires :estimate, type: Hash do
          requires :amount, type: String
          requires :expense_date, type: String
          requires :category_id, type: Integer
          optional :note, type: String
          requires :client_id, type: Integer
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :archive_number, type: String
          optional :archived_at, type: String
          optional :deleted_at, type: String
          optional :tax_1, type: String
          optional :tax_2, type: String
          requires :company_id, type: Integer
        end
      end
      post do
        binding.pry
        Services::Apis::EstimateApiService.create(params)
      end

      desc 'Update Estimate'
      params do
        requires :estimate, type: Hash do
          optional :amount, type: String
          optional :expense_date, type: String
          optional :category_id, type: Integer
          optional :note, type: String
          optional :client_id, type: Integer
          optional :created_at, type: String
          optional :updated_at, type: String
          optional :archive_number, type: String
          optional :archived_at, type: String
          optional :deleted_at, type: String
          optional :tax_1, type: String
          optional :tax_2, type: String
          optional :company_id, type: Integer
        end
      end

      patch ':id' do
        binding.pry
        Services::Apis::EstimateApiService.update(params)
      end


      desc 'Delete an Estimate'
      params do
        requires :id, type: Integer, desc: "Delete an estimate"
      end
      delete ':id' do
        Services::Apis::EstimateApiService.destroy(params[:id])
      end
    end
  end
end
