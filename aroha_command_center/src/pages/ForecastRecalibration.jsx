import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Settings, Sliders, RefreshCw, Activity, CheckCircle2 } from 'lucide-react';

// Mock data: Comparing MAE before and after Alpha recalibration
const tuningData = [
  { category: 'Fuel', oldMae: 5.2, newMae: 3.1, optimalAlpha: 0.85 },
  { category: 'Medical', oldMae: 4.1, newMae: 2.8, optimalAlpha: 0.90 },
  { category: 'Food', oldMae: 6.5, newMae: 5.0, optimalAlpha: 0.40 },
  { category: 'Spares (Reg)', oldMae: 3.8, newMae: 3.6, optimalAlpha: 0.25 },
];

export default function ForecastRecalibration() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 mb-1">System & Forecast Recalibration</h1>
            <p className="text-sm text-slate-500">Backtesting historical Mean Absolute Error (MAE) to tune exponential smoothing parameters.</p>
          </div>
          <button className="bg-[#140F2D] text-white px-5 py-2.5 rounded-xl text-sm font-semibold shadow-md hover:bg-slate-800 transition-colors flex items-center gap-2">
            <RefreshCw size={16} /> Force Recalibration Job
          </button>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-6 mb-6">
          <KpiCard title="Global MAE Reduction" value="-28" suffix="%" subtitle="Since last tuning run" icon={<Activity size={20} className="text-emerald-600"/>} bg="bg-emerald-100" />
          <KpiCard title="Last Scheduled Run" value="02:00" suffix="UTC" subtitle="Job: AlphaRecalibrationService" icon={<Settings size={20} className="text-purple-600"/>} bg="bg-purple-100" />
          <KpiCard title="Parameters Adjusted" value="4" subtitle="Categories updated" icon={<Sliders size={20} className="text-blue-600"/>} bg="bg-blue-100" />
          <KpiCard title="Model Drift Status" value="Stable" subtitle="Within acceptable thresholds" icon={<CheckCircle2 size={20} className="text-emerald-600"/>} bg="bg-emerald-100" />
        </div>

        {/* Middle Row: Tuning Visualization */}
        <div className="grid grid-cols-12 gap-6 mb-6">
          
          {/* Left: MAE Comparison Chart */}
          <div className="col-span-8 bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col">
            <div className="mb-6">
              <h3 className="text-base font-bold text-slate-800">MAE Improvement by Category</h3>
              <p className="text-xs text-slate-500 mt-1">Comparing forecast error before and after parameter ($\alpha$) tuning.</p>
            </div>
            <div className="flex-1 w-full min-h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={tuningData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="category" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#94a3b8'}} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#94a3b8'}} />
                  <Tooltip cursor={{fill: '#f8fafc'}} contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                  <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '20px' }} />
                  <Bar dataKey="oldMae" name="Previous MAE" fill="#e2e8f0" radius={[4, 4, 0, 0]} barSize={30} />
                  <Bar dataKey="newMae" name="Optimized MAE" fill="#6D28D9" radius={[4, 4, 0, 0]} barSize={30} />
                  <Line type="monotone" dataKey="optimalAlpha" name="Selected Alpha (α)" stroke="#10b981" strokeWidth={3} dot={{r: 4}} yAxisId="right" />
                  <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#10b981'}} />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Right: Alpha Configuration Rules */}
          <div className="col-span-4 bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col">
            <h3 className="text-base font-bold text-slate-800 mb-1">Alpha (α) Heuristics</h3>
            <p className="text-xs text-slate-500 mb-6">Current static weights applied to exponential smoothing.</p>
            
            <div className="space-y-4 flex-1">
               <HeuristicRow label="High Responsiveness (α > 0.8)" desc="Used for Fuel & Medical to react instantly to recent consumption spikes." color="bg-red-500" />
               <HeuristicRow label="Balanced (α ≈ 0.5)" desc="Used for Food & Consumables where demand has moderate variance." color="bg-blue-500" />
               <HeuristicRow label="High Smoothing (α < 0.3)" desc="Used for General Spares to ignore random noise in regular demand." color="bg-emerald-500" />
            </div>
            
            <div className="mt-4 p-4 bg-slate-50 rounded-xl border border-slate-100">
               <p className="text-[11px] text-slate-500 leading-relaxed font-medium text-center">
                 *Intermittent demand items (e.g., heavy machinery spares) bypass this logic and route through the Croston/SBA engine.
               </p>
            </div>
          </div>
        </div>

        {/* Bottom Row: Tuning Log */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
           <div className="flex justify-between items-center mb-6">
              <h3 className="text-base font-bold text-slate-800">Parameter Backtesting Log</h3>
           </div>
           
           <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[11px] font-semibold text-slate-400 border-b border-slate-100 uppercase tracking-wider">
                <th className="pb-3 font-medium">Category</th>
                <th className="pb-3 font-medium">Previous Alpha (α)</th>
                <th className="pb-3 font-medium">New Alpha (α)</th>
                <th className="pb-3 font-medium">Validation Metric</th>
                <th className="pb-3 font-medium text-right">Status</th>
              </tr>
            </thead>
            <tbody className="text-sm text-slate-700">
              <TableRow category="Fuel" oldA="0.80" newA="0.85" metric="MAE improved by 40%" status="Applied" />
              <TableRow category="Medical" oldA="0.90" newA="0.90" metric="MAE optimal" status="No Change" />
              <TableRow category="Food" oldA="0.50" newA="0.40" metric="MAE improved by 23%" status="Applied" />
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

function HeuristicRow({ label, desc, color }) {
  return (
    <div>
      <div className="flex items-center gap-2 mb-1">
        <div className={`w-2 h-2 rounded-full ${color}`}></div>
        <span className="font-semibold text-sm text-slate-800">{label}</span>
      </div>
      <p className="text-xs text-slate-500 pl-4">{desc}</p>
    </div>
  );
}

function TableRow({ category, oldA, newA, metric, status }) {
  const isApplied = status === 'Applied';
  return (
    <tr className="border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
      <td className="py-4 font-semibold text-slate-800">{category}</td>
      <td className="py-4 font-mono text-slate-500">{oldA}</td>
      <td className="py-4 font-mono font-bold text-[#6D28D9]">{newA}</td>
      <td className="py-4 text-xs text-slate-600 font-medium">{metric}</td>
      <td className="py-4 text-right">
        <span className={`px-2.5 py-1 rounded-md text-[10px] font-bold uppercase tracking-wider border ${isApplied ? 'text-emerald-700 bg-emerald-50 border-emerald-200' : 'text-slate-600 bg-slate-50 border-slate-200'}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}