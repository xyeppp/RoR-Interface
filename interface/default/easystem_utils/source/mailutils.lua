
-- NOTE: This file is documented with NaturalDocs style comments. All comments begining with "--#' will
-- be included in the output.

MailUtils = {}

------------------------------------------------------------------------------------------------------------------------------------------------
--# Title: Mail Utils
--#     This file contains data manipulation and access utilities similar to <DataUtils>.
------------------------------------------------------------------------------------------------------------------------------------------------

function MailUtils.Initialize()
    RegisterEventHandler (SystemData.Events.MAILBOX_UNREAD_COUNT_CHANGED, "MailUtils.DisplayUnreadCount")
end


function MailUtils.Shutdown()
    UnregisterEventHandler (SystemData.Events.MAILBOX_UNREAD_COUNT_CHANGED, "MailUtils.DisplayUnreadCount")
end

function MailUtils.DisplayUnreadCount(mailboxType, unreadCount)

    local displayString = L""
    
    if (mailboxType == GameData.MailboxType.PLAYER)
    then
        displayString = GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_YOU_HAVE_X_UNREAD_MESSAGES_IN_YOUR_MAILBOX, { L""..unreadCount })
        if (GameData.Mailbox.PLAYER.unreadCount > GameData.Mailbox.PLAYER.oldUnreadCount and not SystemData.Settings.Sound.disableCommunicationSounds)
        then
            Sound.Play( Sound.RECEIVED_NEW_MAIL_FROM_PLAYER )
        end
        GameData.Mailbox.PLAYER.oldUnreadCount = GameData.Mailbox.PLAYER.unreadCount
    elseif (mailboxType == GameData.MailboxType.AUCTION)
    then
        displayString = GetStringFormatFromTable("MailStrings", StringTables.Mail.TEXT_YOU_HAVE_X_UNREAD_MESSAGES_IN_AUCTION_BOX, { L""..unreadCount })
        if (GameData.Mailbox.AUCTION.unreadCount > GameData.Mailbox.AUCTION.oldUnreadCount and not SystemData.Settings.Sound.disableCommunicationSounds)
        then
            Sound.Play( Sound.RECEIVED_NEW_MAIL_FROM_AUCTION )
        end
        GameData.Mailbox.AUCTION.oldUnreadCount = GameData.Mailbox.AUCTION.unreadCount
    end
    
    if (displayString ~= L"")
    then
        TextLogAddEntry( "Chat", SystemData.ChatLogFilters.MISC, displayString )
    end
end
