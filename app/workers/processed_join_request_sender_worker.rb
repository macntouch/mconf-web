# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ProcessedJoinRequestSenderWorker < BaseWorker

  # Finds the join request associated with the activity in `activity_id` and sends
  # a notification to the users that the join request was accepted/declined.
  # Marks the activity as notified.
  def self.perform(activity_id)
    activity = get_recent_activity.find(activity_id)
    join_request = activity.trackable

    return if activity.notified

    if join_request.is_request?
      Resque.logger.info "Sending processed join request notification: #{join_request.inspect}"
      SpaceMailer.processed_join_request_email(join_request.id).deliver
    else
      Resque.logger.info "Sending processed join request invitation notification: #{join_request.inspect}"
      SpaceMailer.processed_invitation_email(join_request.id).deliver
    end

    activity.notified = true
    activity.save!
  end

end
