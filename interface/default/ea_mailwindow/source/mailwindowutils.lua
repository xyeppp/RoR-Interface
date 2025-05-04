MailWindowUtils = {}

-- This function determines the slice name needed so we can populate the mail header icon with the correct image.
function MailWindowUtils.GetHeaderIconSliceName(headerData)

	local sliceName = "mail"
	local readSuffix = "-read"
	local unreadSuffix = "-unread"

	if headerData.attachmentMoney > 0 or 
		(headerData.attachmentIconIDs ~= nil and #headerData.attachmentIconIDs > 0)
	then
		sliceName = "package"
	end

	if headerData.isCOD then 
		sliceName = "cod"
		unreadSuffix = "-unread"
		if headerData.attachmentIconIDs ~= nil and #headerData.attachmentIconIDs > 0 then
			readSuffix = "-untaken"
		else
			readSuffix = "-taken"
		end
	end

	if headerData.hasBeenRead then
		return (sliceName..readSuffix)
	else
		return (sliceName..unreadSuffix)
	end
end

function MailWindowUtils.IsAttachmentTaken(headerData, slotNumber)
	if headerData == nil or slotNumber == nil or #headerData.attachmentsTakenTable <= 0 or slotNumber > #headerData.attachmentsTakenTable then
		return false
	end

	return headerData.attachmentsTakenTable[slotNumber]
end

function MailWindowUtils.ContainsUntakenAttachmentItems(headerData)
	
	-- If there are no items attached, then nothing is untaken.
	if headerData == nil or #headerData.attachmentIconIDs == 0 then
		return false
	end

	-- Loop through the table of attachments taken to see if all attached items have been taken
	for index, data in ipairs (headerData.attachmentsTakenTable) do
		if data == false then
			
			return true
		end
	end

	return false
end

function MailWindowUtils.GetNumberOfTakenAndUntakenAttachmentItems(headerData)
	if headerData == nil or #headerData.attachmentIconIDs == 0 then
		return 0, 0
	end

	local numberOfAttachmentsTaken = 0
	local numberOfAttachmentsNotTaken = 0

	-- Loop through the table of attachments taken to see if all attached items have been taken
	for index, data in ipairs(headerData.attachmentsTakenTable) do
		if data == true then
			numberOfAttachmentsTaken = numberOfAttachmentsTaken + 1
		else
			numberOfAttachmentsNotTaken = numberOfAttachmentsNotTaken + 1
		end
	end

	return numberOfAttachmentsTaken, numberOfAttachmentsNotTaken
end

function MailWindowUtils.ShowDeleteConfirmationDialog(headerData)
		-- Show a delete confirmation dialog if the message hasn't been read,
	if (headerData.hasBeenRead == false) or

		-- ...still contains untaken coins,
		(headerData.attachmentMoney > 0 and headerData.isMoneyTaken == false) or

		-- ...still contains an unpaid COD
		(headerData.isCOD and headerData.isCODPaid == false) or

		-- ...still contains untaken items
		MailWindowUtils.ContainsUntakenAttachmentItems(headerData)
	then
		return true
	else
		return false
	end
end

function MailWindowUtils.PopulateItemAttachments(rowFrame, headerData)
	-- This function shows or hides the attachment related icons for a single header row

	-- If there are attachments
	if headerData.attachmentIconIDs ~= nil and #headerData.attachmentIconIDs > 0 then

		-- If there is only 1 attachment, display its item icon
		if #headerData.attachmentIconIDs == 1 then
			local texture, x, y = GetIconData(headerData.attachmentIconIDs[1])
			DynamicImageSetTexture(rowFrame.."AttachmentButtonIcon", texture, x, y)
			WindowSetShowing(rowFrame.."AttachmentButton", true)
			WindowSetShowing(rowFrame.."MultipleAttachmentsImage", false)

			if MailWindowUtils.ContainsUntakenAttachmentItems(headerData) then
				WindowSetTintColor(rowFrame.."AttachmentButtonIcon", DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
			else
				WindowSetTintColor(rowFrame.."AttachmentButtonIcon", DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)				
			end

		-- If there's more than 1 attachment, show the multi-attachment image instead of the item icon
		else
			WindowSetShowing(rowFrame.."AttachmentButton", false)
			WindowSetShowing(rowFrame.."MultipleAttachmentsImage", true)
			if MailWindowUtils.ContainsUntakenAttachmentItems(headerData) then
				WindowSetTintColor(rowFrame.."MultipleAttachmentsImage", DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
			else
				WindowSetTintColor(rowFrame.."MultipleAttachmentsImage", DefaultColor.MEDIUM_GRAY.r, DefaultColor.MEDIUM_GRAY.g, DefaultColor.MEDIUM_GRAY.b)				
			end
		end

	-- Otherwise there are no attachments, so don't show either the icon nor the multi-attachment image.
	else
		WindowSetShowing(rowFrame.."AttachmentButton", false)
		WindowSetShowing(rowFrame.."MultipleAttachmentsImage", false)
	end
end