#  Copyright (c) 2016, Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Person::MutationsController < ApplicationController
  include AsyncDownload

  before_action :authorize_action

  decorates :group

  def index
    return if request.format.csv? && since.nil?
    respond_to do |format|
      format.html
      format.csv { render_mutations }
    end
  end

  private

  def render_mutations
    with_async_download_cookie(:csv, :mutationen) do |filename|
      Export::MutationsExportJob.new(:csv, current_user.id, since, {filename: filename}).enqueue!
    end
  end

  def since
    @since ||= Date.parse(params[:since] || "")
  rescue ArgumentError
    flash.now[:alert] = I18n.t("person.mutations.index.invalid_date")
    render "index", formats: :html
    nil
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def authorize_action
    authorize!(:index_mutations, group)
  end
end
