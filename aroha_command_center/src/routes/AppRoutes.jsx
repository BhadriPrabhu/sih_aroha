import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Login from '../pages/Login';
import CommandCenterHome from '../pages/CommandCenterHome';
import InventoryRisk from '../pages/InventoryRisk';
import CargoResupply from '../pages/CargoResupply';
import ExpeditionsPersonnel from '../pages/ExpeditionsPersonnel';
import EmergencyMonitor from '../pages/EmergencyMonitor';
import ForecastRecalibration from '../pages/ForecastRecalibration';
import SuperAdminManagement from '../pages/SuperAdminManagement';
import useAuthStore from '../store/useAuthStore';

const ProtectedRoute = ({ children, allowedRoles }) => {
  const { user, isAuthenticated } = useAuthStore();

  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (allowedRoles && !allowedRoles.includes(user.role)) return <Navigate to="/" replace />;

  return children;
};

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route path="/" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN', 'ADMIN']}>
          <CommandCenterHome />
        </ProtectedRoute>
      } />

      <Route path="/inventory" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN', 'ADMIN', 'MANAGER']}>
          <InventoryRisk />
        </ProtectedRoute>
      } />

      <Route path="/cargo" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN', 'ADMIN']}>
          <CargoResupply />
        </ProtectedRoute>
      } />

      <Route path="/expeditions" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN', 'ADMIN', 'EMPLOYEE']}>
          <ExpeditionsPersonnel />
        </ProtectedRoute>
      } />

      <Route path="/alerts" element={
        <ProtectedRoute>
          <EmergencyMonitor />
        </ProtectedRoute>
      } />

      {/* Super Admin ONLY Routes */}
      <Route path="/settings" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN']}>
          <ForecastRecalibration />
        </ProtectedRoute>
      } />

      <Route path="/access-control" element={
        <ProtectedRoute allowedRoles={['SUPER_ADMIN']}>
          <SuperAdminManagement />
        </ProtectedRoute>
      } />

      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}