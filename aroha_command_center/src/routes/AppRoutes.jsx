import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Login from '../pages/Login';
import CommandCenterHome from '../pages/CommandCenterHome';
import InventoryRisk from '../pages/InventoryRisk';
import CargoResupply from '../pages/CargoResupply';
import ExpeditionsPersonnel from '../pages/ExpeditionsPersonnel';
import EmergencyMonitor from '../pages/EmergencyMonitor';
import ForecastRecalibration from '../pages/ForecastRecalibration';

const ProtectedRoute = ({ children, allowedRoles }) => {
  const currentUserRole = 'LOGISTICS_COMMANDER'; 
  const isAuthenticated = true;

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(currentUserRole)) {
    // If they don't have clearance, kick them back to a safe screen
    return <Navigate to="/" replace />;
  }

  return children;
};

export default function AppRoutes() {
  return (
    <Routes>
      {/* Public Route */}
      <Route path="/login" element={<Login />} />

      {/* Protected Central Command Routes (Requires Admin/Super Admin clearance) */}
      <Route path="/" element={
        <ProtectedRoute allowedRoles={['NCPOR_DIRECTOR', 'LOGISTICS_COMMANDER']}>
          <CommandCenterHome />
        </ProtectedRoute>
      } />
      
      <Route path="/inventory" element={
        <ProtectedRoute allowedRoles={['NCPOR_DIRECTOR', 'LOGISTICS_COMMANDER', 'STATION_COMMANDER_BHA']}>
          <InventoryRisk />
        </ProtectedRoute>
      } />
      
      <Route path="/cargo" element={
        <ProtectedRoute allowedRoles={['NCPOR_DIRECTOR', 'LOGISTICS_COMMANDER']}>
          <CargoResupply />
        </ProtectedRoute>
      } />
      
      <Route path="/expeditions" element={
        <ProtectedRoute allowedRoles={['NCPOR_DIRECTOR', 'LOGISTICS_COMMANDER', 'EXPEDITION_LEAD']}>
          <ExpeditionsPersonnel />
        </ProtectedRoute>
      } />
      
      <Route path="/alerts" element={
        <ProtectedRoute> {/* Accessible by all authenticated operational staff */}
          <EmergencyMonitor />
        </ProtectedRoute>
      } />
      
      {/* Super Admin ONLY Route */}
      <Route path="/settings" element={
        <ProtectedRoute allowedRoles={['NCPOR_DIRECTOR']}>
          <ForecastRecalibration />
        </ProtectedRoute>
      } />
      
      {/* Fallback routing */}
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}