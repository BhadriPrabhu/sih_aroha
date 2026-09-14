import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import CommandCenterHome from '../pages/CommandCenterHome';
import InventoryRisk from '../pages/InventoryRisk';
import CargoResupply from '../pages/CargoResupply';
import ExpeditionsPersonnel from '../pages/ExpeditionsPersonnel';
import EmergencyMonitor from '../pages/EmergencyMonitor';
import ForecastRecalibration from '../pages/ForecastRecalibration';

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<CommandCenterHome />} />
      <Route path="/inventory" element={<InventoryRisk />} />
      <Route path="/cargo" element={<CargoResupply />} />
      <Route path="/expeditions" element={<ExpeditionsPersonnel />} />
      <Route path="/alerts" element={<EmergencyMonitor />} />
      <Route path="/settings" element={<ForecastRecalibration />} />
      
      {/* Fallback routing */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}