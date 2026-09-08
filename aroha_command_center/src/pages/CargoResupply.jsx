import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell, PieChart, Pie } from 'recharts';
import { Anchor, Box, Scale, AlertOctagon, CheckCircle2, AlertTriangle, XCircle } from 'lucide-react';

// Mock data: Capacity Utilization across recent optimization runs
const capacityData = [
  { run: 'OPT-01', capacity: 10000, used: 9500 },
  { run: 'OPT-02', capacity: 12000, used: 11800 },
  { run: 'OPT-03', capacity: 8000, used: 7900 },
  { run: 'OPT-04', capacity: 15000, used: 14200 },
];

// Mock data: Cargo makeup by category for the active run
const cargoMakeupData = [
  { name: 'Fuel', value: 400, color: '#f97316' },
  { name: 'Food', value: 180, color: '#3b82f6' },
  { name: 'Medical', value: 20, color: '#10b981' },
];

export default function CargoResupply() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 mb-1">Cargo & Resupply Optimization</h1>
            <p className="text-sm text-slate-500">Bounded knapsack asset allocation and capacity planning.</p>
          </div>
          <button className="bg-[#6D28D9] text-white px-5 py-2.5 rounded-xl text-sm font-semibold shadow-md shadow-purple-900/20 hover:bg-purple-700 transition-colors">
            + Run Optimizer
          </button>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-6 mb-6">
          <KpiCard title="Max Weight Constraint (W)" value="15,000" subtitle="Total Fleet Capacity" suffix="kg" icon={<Scale size={20} className="text-blue-600"/>} bg="bg-blue-100" />
          <KpiCard title="Avg. Capacity Util." value="95.8" subtitle="Knapsack Efficiency" suffix="%" icon={<Box size={20} className="text-emerald-600"/>} bg="bg-emerald-100" />
          <KpiCard title="Critical Fulfillment" value="89" subtitle="High-Risk Items Satisfied" suffix="%" icon={<CheckCircle2 size={20} className="text-purple-600"/>} bg="bg-purple-100" />
          <KpiCard title="Global Residual Risk" value="Med" subtitle="Post-Optimization Risk" icon={<AlertOctagon size={20} className="text-amber-600"/>} bg="bg-amber-100" />
        </div>

        {/* Middle Row: Charts */}
        <div className="grid grid-cols-12 gap-6 mb-6">
          {/* Left Chart: Capacity Over Time */}
          <div className="col-span-8 bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col">
            <div className="mb-6 flex justify-between items-center">
              <div>
                <h3 className="text-base font-bold text-slate-800">Weight Capacity vs. Utilized Cargo</h3>
                <p className="text-xs text-slate-500 mt-1">DP Algorithm packing efficiency across recent resupply windows.</p>
              </div>
            </div>
            <div className="flex-1 w-full min-h-[200px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={capacityData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="run" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#94a3b8'}} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#94a3b8'}} />
                  <Tooltip cursor={{fill: '#f8fafc'}} contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                  <Bar dataKey="capacity" name="Max Capacity (kg)" fill="#e2e8f0" radius={[4, 4, 0, 0]} barSize={40} />
                  <Bar dataKey="used" name="Utilized Weight (kg)" fill="#6D28D9" radius={[4, 4, 0, 0]} barSize={40} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Right Chart: Run Summary */}
          <div className="col-span-4 bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
            <h3 className="text-base font-bold text-slate-800 mb-1">Active Run: OPT-2026-BHA-01</h3>
            <p className="text-xs text-slate-500 mb-4">Destination: Bharati Station</p>
            
            <div className="h-[140px] flex justify-center items-center relative">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={cargoMakeupData} innerRadius={50} outerRadius={70} paddingAngle={2} dataKey="value">
                    {cargoMakeupData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex items-center justify-center flex-col pointer-events-none">
                 <span className="text-xl font-bold text-slate-800">95%</span>
                 <span className="text-[10px] text-slate-400 uppercase font-semibold">Packed</span>
              </div>
            </div>
            
            <div className="space-y-3 mt-4">
               {cargoMakeupData.map(item => (
                 <div key={item.name} className="flex items-center justify-between text-sm">
                   <div className="flex items-center gap-2">
                     <span className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }}></span>
                     <span className="font-medium text-slate-600">{item.name}</span>
                   </div>
                   <span className="font-bold text-slate-800">{item.value} units</span>
                 </div>
               ))}
            </div>
          </div>
        </div>

        {/* Bottom Row: DP Knapsack Output Table (Using EXACT data from your ML Doc) */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
           <div className="flex justify-between items-center mb-6">
              <div>
                <h3 className="text-base font-bold text-slate-800">Knapsack Optimizer Selections</h3>
                <p className="text-xs text-slate-500 mt-1">Objective: Maximize risk reduction subject to capacity constraints.</p>
              </div>
           </div>
           
           <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[11px] font-semibold text-slate-400 border-b border-slate-100 uppercase tracking-wider">
                <th className="pb-3 font-medium">Item Name</th>
                <th className="pb-3 font-medium">Criticality Input</th>
                <th className="pb-3 font-medium">Required Qty</th>
                <th className="pb-3 font-medium">Selected Qty</th>
                <th className="pb-3 font-medium">Fulfillment</th>
                <th className="pb-3 font-medium text-right">Optimization Status</th>
              </tr>
            </thead>
            <tbody className="text-sm text-slate-700">
              <TableRow 
                name="Medical Kit" criticality="0.94" required="20" selected="20" 
                fulfillment="100%" status="Fully Fulfilled" statusIcon={<CheckCircle2 size={16} className="text-emerald-500"/>} 
              />
              <TableRow 
                name="Winter Diesel Bulk (Fuel)" criticality="0.89" required="500 L" selected="400 L" 
                fulfillment="80%" status="Partially Fulfilled" statusIcon={<AlertTriangle size={16} className="text-amber-500"/>} 
              />
              <TableRow 
                name="Ration Pack B (Food)" criticality="0.61" required="300 kg" selected="180 kg" 
                fulfillment="60%" status="Partially Fulfilled" statusIcon={<AlertTriangle size={16} className="text-amber-500"/>} 
              />
              <TableRow 
                name="Spare Part A" criticality="0.22" required="10" selected="0" 
                fulfillment="0%" status="Deprioritized (Capacity)" statusIcon={<XCircle size={16} className="text-red-500"/>} disabled 
              />
            </tbody>
          </table>
        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components
function KpiCard({ title, value, suffix, subtitle, icon, bg }) {
  return (
    <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4">
      <div className={`p-3 rounded-xl ${bg}`}>
        {icon}
      </div>
      <div>
        <h3 className="text-xs font-medium text-slate-500 mb-0.5">{title}</h3>
        <div className="text-2xl font-bold text-slate-800 leading-none">
          {value}<span className="text-sm font-medium text-slate-400 ml-1">{suffix}</span>
        </div>
        {subtitle && <p className="text-[10px] text-slate-400 mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}

function TableRow({ name, criticality, required, selected, fulfillment, status, statusIcon, disabled }) {
  return (
    <tr className={`border-b border-slate-50 hover:bg-slate-50/50 transition-colors ${disabled ? 'opacity-50' : ''}`}>
      <td className="py-4">
        <div className="font-semibold text-slate-800">{name}</div>
      </td>
      <td className="py-4">
        <span className="font-mono bg-slate-100 text-slate-600 px-2 py-1 rounded text-xs">{criticality}</span>
      </td>
      <td className="py-4 font-medium text-slate-500">{required}</td>
      <td className="py-4 font-bold text-slate-800">{selected}</td>
      <td className="py-4">
        <div className="flex items-center gap-2">
           <div className="w-16 bg-slate-100 rounded-full h-1.5">
             <div className="bg-[#6D28D9] h-1.5 rounded-full" style={{ width: fulfillment }}></div>
           </div>
           <span className="text-xs font-bold text-slate-700">{fulfillment}</span>
        </div>
      </td>
      <td className="py-4 text-right">
        <div className="flex items-center justify-end gap-2 text-xs font-medium text-slate-600">
           {status}
           {statusIcon}
        </div>
      </td>
    </tr>
  );
}