import React, { createContext, useContext, useState, useEffect } from 'react';

const API_BASE = 'http://127.0.0.1:8000/api';

const AppContext = createContext(null);

export function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [skills, setSkills] = useState([]);
  const [inventory, setInventory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [notification, setNotification] = useState(null);
  const [completionResult, setCompletionResult] = useState(null);

  const fetchAllData = async () => {
    try {
      setLoading(true);
      const [userRes, tasksRes, skillsRes, invRes] = await Promise.all([
        fetch(`${API_BASE}/user`),
        fetch(`${API_BASE}/tasks`),
        fetch(`${API_BASE}/skills`),
        fetch(`${API_BASE}/inventory`)
      ]);
      const userData = await userRes.json();
      const tasksData = await tasksRes.json();
      const skillsData = await skillsRes.json();
      const invData = await invRes.json();
      setUser(userData);
      setTasks(tasksData);
      setSkills(skillsData);
      setInventory(invData);
    } catch (err) {
      console.error("Failed to fetch:", err);
      showNotification("SYSTEM ERROR: Cannot connect to server.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const showNotification = (msg) => {
    setNotification(msg);
    setTimeout(() => setNotification(null), 3000);
  };

  const handleAssignStat = async (statName) => {
    try {
      const res = await fetch(`${API_BASE}/user/assign_stats`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ [statName]: 1 })
      });
      if (res.ok) {
        const updatedUser = await res.json();
        setUser(updatedUser);
        showNotification(`Stat point assigned to ${statName.toUpperCase()}`);
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to assign stat.");
    }
  };

  const handleUpdateProfile = async (profileData) => {
    try {
      const res = await fetch(`${API_BASE}/user/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(profileData)
      });
      if (res.ok) {
        const updatedUser = await res.json();
        setUser(updatedUser);
        showNotification("Profile updated successfully.");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to update profile.");
    }
  };

  const handleCreateTask = async (taskData) => {
    try {
      const res = await fetch(`${API_BASE}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData)
      });
      if (res.ok) {
        await fetchAllData();
        showNotification("New Quest Registered.");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to create quest.");
    }
  };

  const handleUpdateTask = async (taskId, taskData) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData)
      });
      if (res.ok) {
        await fetchAllData();
        showNotification("Quest Updated.");
      } else {
        const err = await res.json();
        showNotification(err.detail || "Failed to update quest.");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to update quest.");
    }
  };

  const handleDeleteTask = async (taskId) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}`, { method: 'DELETE' });
      if (res.ok) {
        await fetchAllData();
        showNotification("Quest Deleted.");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to delete quest.");
    }
  };

  const handleCompleteTask = async (taskId) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}/complete`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setCompletionResult(data);
      } else {
        const errData = await res.json();
        showNotification(errData.detail || "Failed to complete quest.");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to complete quest.");
    }
  };

  const clearCompletionAndRefresh = () => {
    setCompletionResult(null);
    fetchAllData();
  };

  const handleCastSkill = async (skillId) => {
    try {
      const res = await fetch(`${API_BASE}/skills/${skillId}/cast`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setUser(prev => ({ ...prev, mp: data.mp_remaining }));
        showNotification(`SYSTEM: ${data.message}`);
      } else {
        const errData = await res.json();
        showNotification(`FAIL: ${errData.detail}`);
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to cast skill.");
    }
  };

  return (
    <AppContext.Provider value={{
      user, tasks, skills, inventory, loading, notification, completionResult,
      fetchAllData, showNotification, clearCompletionAndRefresh,
      handleAssignStat, handleUpdateProfile,
      handleCreateTask, handleUpdateTask, handleDeleteTask, handleCompleteTask,
      handleCastSkill,
    }}>
      {children}
    </AppContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp must be used within AppProvider");
  return ctx;
}
