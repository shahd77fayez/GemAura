// lib/src/data/providers/app_state_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

import 'package:gemma_final_app/src/data/models/task_model.dart';
import 'package:gemma_final_app/src/data/models/reminder_model.dart';
import 'package:gemma_final_app/src/data/models/emotion_log_model.dart';
import 'package:gemma_final_app/src/data/models/condition_model.dart'; // Just in case mock data is used directly, though not currently

class AppStateProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Reminder> _reminders = [];
  List<EmotionLog> _emotionLogs = [];
  bool _isBluetoothConnected = false;
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  List<Reminder> get reminders => _reminders;
  List<EmotionLog> get emotionLogs => _emotionLogs;
  bool get isBluetoothConnected => _isBluetoothConnected;
  bool get isLoading => _isLoading;

  AppStateProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedTasks = prefs.getString('tasks');
      if (storedTasks != null) {
        _tasks = (json.decode(storedTasks) as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _tasks = MOCK_TASKS; // Use mock data if nothing stored
      }

      final storedReminders = prefs.getString('reminders');
      if (storedReminders != null) {
        _reminders = (json.decode(storedReminders) as List)
            .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _reminders = MOCK_REMINDERS; // Use mock data if nothing stored
      }

      final storedEmotionLogs = prefs.getString('emotionLogs');
      if (storedEmotionLogs != null) {
        _emotionLogs = (json.decode(storedEmotionLogs) as List)
            .map((e) => EmotionLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _isBluetoothConnected = prefs.getBool('bluetoothConnected') ?? false;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    if (_isLoading) return; // Don't save while still loading initial data

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', json.encode(_tasks.map((e) => e.toJson()).toList()));
      await prefs.setString('reminders', json.encode(_reminders.map((e) => e.toJson()).toList()));
      await prefs.setString('emotionLogs', json.encode(_emotionLogs.map((e) => e.toJson()).toList()));
      await prefs.setBool('bluetoothConnected', _isBluetoothConnected);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Task management
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
    _saveData();
  }

  void toggleTaskCompletion(String id) {
    _tasks = _tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();
    notifyListeners();
    _saveData();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    _saveData();
  }

  // Reminder management
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
    _saveData();
  }

  void toggleReminderCompletion(String id) {
    _reminders = _reminders.map((reminder) {
      if (reminder.id == id) {
        return reminder.copyWith(isCompleted: !reminder.isCompleted);
      }
      return reminder;
    }).toList();
    notifyListeners();
    _saveData();
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((reminder) => reminder.id == id);
    notifyListeners();
    _saveData();
  }

  // Emotion tracking
  void addEmotionLog(EmotionLog log) {
    _emotionLogs.add(log);
    notifyListeners();
    _saveData();
  }

  // Bluetooth connection
  void toggleBluetoothConnection() {
    _isBluetoothConnected = !_isBluetoothConnected;
    notifyListeners();
    _saveData();
  }
}