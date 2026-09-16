import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell, PieChart, Pie } from 'recharts';
import { Anchor, Box, Scale, AlertOctagon, CheckCircle2, AlertTriangle, XCircle, Check, Loader2 } from 'lucide-react';

// Mock data: Capacity Utilization across recent optimization runs
const capacityData = [
  { run: 'OPT-01', capacity: 10000, used: 9500 },
  { run: 'OPT-02', capacity: 12000, used: 11800 },
  { run: 'OPT-03', capacity: 8000, used: 7900 },
  { run: 'OPT-04', capacity: 15000, used: 14200 },
];

// Mock data: Cargo makeup by category for the active run - UPDATED TO TACTICAL PALETTE
const cargoMakeupData = [
  { name: 'Fuel', value: 400, color: '#F59E0B' }, // Amber
  { name: 'Food', value: 180, color: '#0284C7' }, // Sky Blue
  { name: 'Medical', value: 20, color: '#10B981' }, // Emerald
];

export default function CargoResupply() {

  const [optimizationState, setOptimizationState] = useState('idle');

  const handleRunOptimizer = () => {
    if (optimizationState === 'running') return;

    setOptimizationState('running');

    setTimeout(() => {
      setOptimizationState('success');

      setTimeout(() => {
        setOptimizationState('idle');
      }, 3000);
    }, 2500);
  };

  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">

        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-1">Cargo & Resupply Optimization</h1>
            <p className="text-sm font-medium text-slate-500">Bounded knapsack asset allocation and capacity planning.</p>
          </div>
          <button
            onClick={handleRunOptimizer}
            disabled={optimizationState === 'running'}
            className={`px-5 py-2 rounded-md text-sm font-bold shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 flex items-center justify-center min-w-[160px] ${optimizationState === 'running'
                ? 'bg-slate-900 text-slate-300 cursor-not-allowed hover:bg-slate-800 focus:ring-slate-800'
                : optimizationState === 'success'
                  ? 'bg-emerald-500 text-white hover:bg-emerald-500 focus:ring-emerald-500'
                  : 'bg-slate-900 text-white hover:bg-slate-800 focus:ring-slate-800'
              }`}
          >
            {optimizationState === 'running' && (
              <span className="flex items-center gap-2"><Loader2 size={16} className="animate-spin" /> Executing DP...</span>
            )}
            {optimizationState === 'success' && (
              <span className="flex items-center gap-2"><Check size={16} /> Run Successful</span>
            )}
            {optimizationState === 'idle' && 'Run Optimizer'}
          </button>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <KpiCard title="Max Weight Constraint" value="15,000" subtitle="Total Fleet Capacity" suffix="kg" icon={<Scale size={18} />} />
          <KpiCard title="Avg. Capacity Util." value="95.8" subtitle="Knapsack Efficiency" suffix="%" icon={<Box size={18} />} />
          <KpiCard title="Critical Fulfillment" value="89" subtitle="High-Risk Items Satisfied" suffix="%" icon={<CheckCircle2 size={18} />} />
          <KpiCard title="Global Residual Risk" value="Med" subtitle="Post-Optimization Risk" icon={<AlertOctagon size={18} />} />
        </div>

        {/* Middle Row: Charts */}
        <div className="grid grid-cols-12 gap-6 mb-6">
          {/* Left Chart: Capacity Over Time */}
          <div className="col-span-8 bg-white rounded-lg p-6 shadow-sm border border-slate-200 flex flex-col">
            <div className="mb-6 flex justify-between items-center border-b border-slate-100 pb-4">
              <div>
                <h3 className="text-lg font-bold text-slate-900">Weight Capacity vs. Utilized Cargo</h3>
                <p className="text-xs text-slate-500">DP Algorithm packing efficiency across recent resupply windows.</p>
              </div>
            </div>
            <div className="flex-1 w-full min-h-[220px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={capacityData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                  <XAxis dataKey="run" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} />
                  <Tooltip cursor={{ fill: '#F8FAFC' }} contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' }} />
                  {/* Replaced purple with tactical slate and industrial blue */}
                  <Bar dataKey="capacity" name="Max Capacity (kg)" fill="#CBD5E1" radius={[2, 2, 0, 0]} barSize={36} />
                  <Bar dataKey="used" name="Utilized Weight (kg)" fill="#0F172A" radius={[2, 2, 0, 0]} barSize={36} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Right Chart: Run Summary */}
          <div className="col-span-4 bg-white rounded-lg p-6 shadow-sm border border-slate-200">
            <div className="border-b border-slate-100 pb-4 mb-4">
              <h3 className="text-lg font-bold text-slate-900">Active Run: OPT-2026-BHA-01</h3>
              <p className="text-xs font-medium text-slate-500">Destination: Bharati Station</p>
            </div>

            <div className="h-[140px] flex justify-center items-center relative">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={cargoMakeupData} innerRadius={50} outerRadius={65} paddingAngle={2} dataKey="value" stroke="none">
                    {cargoMakeupData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: 'none' }} />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex items-center justify-center flex-col pointer-events-none">
                <span className="text-xl font-bold text-slate-900 tracking-tight">95%</span>
                <span className="text-[10px] text-slate-500 uppercase font-bold tracking-wider">Utilized</span>
              </div>
            </div>

            <div className="space-y-3 mt-6">
              {cargoMakeupData.map(item => (
                <div key={item.name} className="flex items-center justify-between text-sm border-t border-slate-50 pt-2">
                  <div className="flex items-center gap-2">
                    <span className="w-2.5 h-2.5 rounded-sm" style={{ backgroundColor: item.color }}></span>
                    <span className="font-semibold text-slate-700">{item.name}</span>
                  </div>
                  <span className="font-bold text-slate-900">{item.value} <span className="text-xs font-medium text-slate-500 font-mono">UNITS</span></span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Bottom Row: DP Knapsack Output Table */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-slate-200">
          <div className="flex justify-between items-center mb-6">
            <div>
              <h3 className="text-lg font-bold text-slate-900">Knapsack Optimizer Selections</h3>
              <p className="text-xs font-medium text-slate-500">Objective: Maximize risk reduction subject to capacity constraints.</p>
            </div>
          </div>

          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[12px] font-semibold text-slate-500 border-b border-slate-200 bg-slate-50">
                <th className="py-3 px-4 font-semibold rounded-tl-md">Item Name</th>
                <th className="py-3 px-4 font-semibold">Criticality Input</th>
                <th className="py-3 px-4 font-semibold">Required Qty</th>
                <th className="py-3 px-4 font-semibold">Selected Qty</th>
                <th className="py-3 px-4 font-semibold">Fulfillment</th>
                <th className="py-3 px-4 font-semibold text-right rounded-tr-md">Optimization Status</th>
              </tr>
            </thead>
            <tbody className="text-sm text-slate-700">
              <TableRow
                name="Medical Kit" criticality="0.94" required="20" selected="20"
                fulfillment="100%" status="Fully Fulfilled" statusIcon={<CheckCircle2 size={14} className="text-emerald-600" />}
              />
              <TableRow
                name="Winter Diesel Bulk (Fuel)" criticality="0.89" required="500 L" selected="400 L"
                fulfillment="80%" status="Partially Fulfilled" statusIcon={<AlertTriangle size={14} className="text-amber-500" />}
              />
              <TableRow
                name="Ration Pack B (Food)" criticality="0.61" required="300 kg" selected="180 kg"
                fulfillment="60%" status="Partially Fulfilled" statusIcon={<AlertTriangle size={14} className="text-amber-500" />}
              />
              <TableRow
                name="Spare Part A" criticality="0.22" required="10" selected="0"
                fulfillment="0%" status="Deprioritized (Capacity)" statusIcon={<XCircle size={14} className="text-rose-600" />} disabled
              />
            </tbody>
          </table>
        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components - REFACTORED FOR CRISP GEOMETRY AND MONOTONE ICONS
function KpiCard({ title, value, suffix, subtitle, icon }) {
  return (
    <div className="bg-white p-5 rounded-lg border border-slate-200 shadow-sm flex items-start gap-4">
      <div className="p-2 border border-slate-200 rounded-md bg-slate-50 text-slate-600">
        {icon}
      </div>
      <div>
        <h3 className="text-[12px] font-semibold text-slate-500 mb-1">{title}</h3>
        <div className="text-2xl font-bold text-slate-900 tracking-tight leading-none">
          {value}<span className="text-sm font-medium text-slate-500 ml-1">{suffix}</span>
        </div>
        {subtitle && <p className="text-[10px] text-slate-400 mt-2 font-medium">{subtitle}</p>}
      </div>
    </div>
  );
}

function TableRow({ name, criticality, required, selected, fulfillment, status, statusIcon, disabled }) {
  return (
    <tr className={`border-b border-slate-100 hover:bg-slate-50 transition-colors ${disabled ? 'opacity-60 bg-slate-50/50' : ''}`}>
      <td className="py-3 px-4">
        <div className="font-semibold text-slate-900">{name}</div>
      </td>
      <td className="py-3 px-4">
        <span className="font-mono bg-slate-100 text-slate-600 border border-slate-200 px-2 py-0.5 rounded text-xs font-semibold">{criticality}</span>
      </td>
      <td className="py-3 px-4 font-medium text-slate-500">{required}</td>
      <td className="py-3 px-4 font-bold text-slate-900">{selected}</td>
      <td className="py-3 px-4">
        <div className="flex items-center gap-3">
          <div className="w-16 bg-slate-200 rounded-sm h-1.5 overflow-hidden">
            {/* Replaced purple with industrial sky blue */}
            <div className="bg-sky-600 h-1.5 rounded-sm" style={{ width: fulfillment }}></div>
          </div>
          <span className="text-xs font-bold text-slate-700">{fulfillment}</span>
        </div>
      </td>
      <td className="py-3 px-4 text-right">
        <div className="flex items-center justify-end gap-2 text-[10px] font-bold text-slate-700">
          {status}
          {statusIcon}
        </div>
      </td>
    </tr>
  );
}