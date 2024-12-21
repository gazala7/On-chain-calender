// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CalendarReminder {
    struct Reminder {
        string title;
        string description;
        uint256 reminderTime;
        bool completed;
    }
    
    // Mapping from user address to their reminders
    mapping(address => Reminder[]) public userReminders;
    
    // Events
    event ReminderCreated(address indexed user, uint256 reminderId, string title, uint256 reminderTime);
    event ReminderCompleted(address indexed user, uint256 reminderId);
    event ReminderUpdated(address indexed user, uint256 reminderId);
    
    // Create a new reminder
    function createReminder(
        string memory _title,
        string memory _description,
        uint256 _reminderTime
    ) public {
        require(_reminderTime > block.timestamp, "Reminder time must be in the future");
        
        Reminder memory newReminder = Reminder({
            title: _title,
            description: _description,
            reminderTime: _reminderTime,
            completed: false
        });
        
        userReminders[msg.sender].push(newReminder);
        
        emit ReminderCreated(
            msg.sender,
            userReminders[msg.sender].length - 1,
            _title,
            _reminderTime
        );
    }
    
    // Mark a reminder as completed
    function completeReminder(uint256 _reminderId) public {
        require(_reminderId < userReminders[msg.sender].length, "Invalid reminder ID");
        require(!userReminders[msg.sender][_reminderId].completed, "Reminder already completed");
        
        userReminders[msg.sender][_reminderId].completed = true;
        emit ReminderCompleted(msg.sender, _reminderId);
    }
    
    // Update an existing reminder
    function updateReminder(
        uint256 _reminderId,
        string memory _title,
        string memory _description,
        uint256 _reminderTime
    ) public {
        require(_reminderId < userReminders[msg.sender].length, "Invalid reminder ID");
        require(_reminderTime > block.timestamp, "Reminder time must be in the future");
        
        Reminder storage reminder = userReminders[msg.sender][_reminderId];
        reminder.title = _title;
        reminder.description = _description;
        reminder.reminderTime = _reminderTime;
        
        emit ReminderUpdated(msg.sender, _reminderId);
    }
    
    // Get all reminders for the calling user
    function getMyReminders() public view returns (Reminder[] memory) {
        return userReminders[msg.sender];
    }
    
    // Get a specific reminder
    function getReminder(uint256 _reminderId) public view returns (Reminder memory) {
        require(_reminderId < userReminders[msg.sender].length, "Invalid reminder ID");
        return userReminders[msg.sender][_reminderId];
    }
    
    // Get upcoming reminders (within the next specified seconds)
    function getUpcomingReminders(uint256 _timeWindow) public view returns (Reminder[] memory) {
        Reminder[] memory allReminders = userReminders[msg.sender];
        uint256 count = 0;
        
        // First, count upcoming reminders
        for (uint256 i = 0; i < allReminders.length; i++) {
            if (!allReminders[i].completed &&
                allReminders[i].reminderTime > block.timestamp &&
                allReminders[i].reminderTime <= block.timestamp + _timeWindow) {
                count++;
            }
        }
        
        // Create array of correct size
        Reminder[] memory upcomingReminders = new Reminder[](count);
        uint256 index = 0;
        
        // Fill array with upcoming reminders
        for (uint256 i = 0; i < allReminders.length; i++) {
            if (!allReminders[i].completed &&
                allReminders[i].reminderTime > block.timestamp &&
                allReminders[i].reminderTime <= block.timestamp + _timeWindow) {
                upcomingReminders[index] = allReminders[i];
                index++;
            }
        }
        
        return upcomingReminders;
    }
}