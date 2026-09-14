import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Settings, Sliders, RefreshCw, Activity, CheckCircle2, Check, Loader2 } from 'lucide-react';

// Mock data: Comparing MAE before and after Alpha recalibration
const tuningData = [
  { category: 'Fuel', oldMae: 5.2, newMae: 3.1, optimalAlpha: 0.85 },
  { category: 'Medical', oldMae: 4.1, newMae: 2.8, optimalAlpha: 0.90 },
  { category: 'Food', oldMae: 6.5, newMae: 5.0, optimalAlpha: 0.40 },
  { category: 'Spares (Reg)', oldMae: 3.8, newMae: 3.6, optimalAlpha: 0.25 },
];

export default function ForecastRecalibration() {

  const [recalState, setRecalState] = useState('idle');

  const handleRecalibrate = () => {
    if (recalState === 'running') return;
    setRecalState('running');

    setTimeout(() => {
      setRecalState('success');
      setTimeout(() => setRecalState('idle'), 3000);
    }, 2800);
  };

  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">

        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-1">System & Forecast Recalibration</h1>
            <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">Backtesting historical Mean Absolute Error (MAE) to tune exponential smoothing parameters.</p>
          </div>
          <button
            onClick={handleRecalibrate}
            disabled={recalState === 'running'}
            className={`px-5 py-2 rounded-md text-sm font-semibold shadow-sm transition-all flex items-center justify-center gap-2 min-w-[210px] focus:outline-none focus:ring-2 focus:ring-offset-2 ${recalState === 'running'
                ? 'bg-slate-200 text-slate-500 cursor-not-allowed focus:ring-slate-200'
                : recalState === 'success'
                  ? 'bg-emerald-600 text-white hover:bg-emerald-700 focus:ring-emerald-500'
                  : 'bg-slate-900 text-white hover:bg-slate-800 focus:ring-slate-900'
              }`}
          >
            {recalState === 'idle' && <><RefreshCw size={14} /> Force Recalibration Job</>}
            {recalState === 'running' && <><Loader2 size={14} className="animate-spin" /> Backtesting MAE...</>}
            {recalState === 'success' && <><Check size={14} /> Tuning Complete</>}
          </button>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <KpiCard title="Global MAE Reduction" value="-28" suffix="%" subtitle="Since last tuning run" icon={<Activity size={18} />} />
          <KpiCard title="Last Scheduled Run" value="02:00" suffix="UTC" subtitle="Job: AlphaRecalibration" icon={<Settings size={18} />} />
          <KpiCard title="Parameters Adjusted" value="4" subtitle="Categories updated" icon={<Sliders size={18} />} />
          <KpiCard title="Model Drift Status" value="Stable" subtitle="Within acceptable thresholds" icon={<CheckCircle2 size={18} />} />
        </div>

        {/* Middle Row: Tuning Visualization */}
        <div className="grid grid-cols-12 gap-6 mb-6">

          {/* Left: MAE Comparison Chart */}
          <div className="col-span-8 bg-white rounded-lg p-6 shadow-sm border border-slate-200 flex flex-col">
            <div className="mb-6 border-b border-slate-100 pb-4">
              <h3 className="text-sm font-bold text-slate-900 tracking-tight uppercase">MAE Improvement by Category</h3>
              <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Comparing forecast error before and after parameter (α) tuning.</p>
            </div>
            <div className="flex-1 w-full min-h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={tuningData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                  <XAxis dataKey="category" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} />
                  <Tooltip cursor={{ fill: '#F8FAFC' }} contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' }} />
                  <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '20px', fontWeight: 600, color: '#475569' }} />
                  {/* Replaced purple/soft colors with tactical slate and sky */}
                  <Bar dataKey="oldMae" name="Previous MAE" fill="#CBD5E1" radius={[2, 2, 0, 0]} barSize={28} />
                  <Bar dataKey="newMae" name="Optimized MAE" fill="#0F172A" radius={[2, 2, 0, 0]} barSize={28} />
                  <Line type="monotone" dataKey="optimalAlpha" name="Selected Alpha (α)" stroke="#0284C7" strokeWidth={2} dot={{ r: 4, fill: '#0284C7', strokeWidth: 2, stroke: '#fff' }} yAxisId="right" />
                  <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#0284C7', fontWeight: 600 }} />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Right: Alpha Configuration Rules */}
          <div className="col-span-4 bg-white rounded-lg p-6 shadow-sm border border-slate-200 flex flex-col">
            <div className="border-b border-slate-100 pb-4 mb-4">
              <h3 className="text-sm font-bold text-slate-900 tracking-tight uppercase">Alpha (α) Heuristics</h3>
              <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Current static weights applied to exponential smoothing.</p>
            </div>

            <div className="space-y-4 flex-1">
              <HeuristicRow label="High Responsiveness (α > 0.8)" desc="Used for Fuel & Medical to react instantly to recent consumption spikes." color="bg-rose-600" />
              <HeuristicRow label="Balanced (α ≈ 0.5)" desc="Used for Food & Consumables where demand has moderate variance." color="bg-sky-600" />
              <HeuristicRow label="High Smoothing (α < 0.3)" desc="Used for General Spares to ignore random noise in regular demand." color="bg-emerald-600" />
            </div>

            <div className="mt-4 p-4 bg-slate-50 rounded-md border border-slate-200">
              <p className="text-[10px] text-slate-600 leading-relaxed font-bold uppercase tracking-wide text-center">
                *Intermittent demand items (e.g., heavy machinery spares) bypass this logic and route through the Croston/SBA engine.
              </p>
            </div>
          </div>
        </div>

        {/* Bottom Row: Tuning Log */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-slate-200">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-sm font-bold text-slate-900 tracking-tight uppercase">Parameter Backtesting Log</h3>
          </div>

          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[10px] font-bold text-slate-500 border-b border-slate-200 uppercase tracking-wider bg-slate-50">
                <th className="py-3 px-4 rounded-tl-md">Category</th>
                <th className="py-3 px-4">Previous Alpha (α)</th>
                <th className="py-3 px-4">New Alpha (α)</th>
                <th className="py-3 px-4">Validation Metric</th>
                <th className="py-3 px-4 text-right rounded-tr-md">Status</th>
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

// Sub-components - REFACTORED FOR ENTERPRISE DENSITY
function KpiCard({ title, value, suffix, subtitle, icon }) {
  return (
    <div className="bg-white p-5 rounded-lg border border-slate-200 shadow-sm flex items-start gap-4">
      <div className="p-2 border border-slate-200 rounded-md bg-slate-50 text-slate-600">
        {icon}
      </div>
      <div>
        <h3 className="text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">{title}</h3>
        <div className="text-2xl font-bold text-slate-900 tracking-tight leading-none">
          {value}<span className="text-sm font-medium text-slate-500 ml-1">{suffix}</span>
        </div>
        {subtitle && <p className="text-[10px] text-slate-400 mt-2 font-medium uppercase tracking-wider">{subtitle}</p>}
      </div>
    </div>
  );
}

function HeuristicRow({ label, desc, color }) {
  return (
    <div>
      <div className="flex items-center gap-2 mb-1">
        <div className={`w-1.5 h-1.5 rounded-sm ${color}`}></div>
        <span className="font-bold text-xs text-slate-900 tracking-tight uppercase">{label}</span>
      </div>
      <p className="text-xs text-slate-600 pl-3.5 font-medium">{desc}</p>
    </div>
  );
}

function TableRow({ category, oldA, newA, metric, status }) {
  const isApplied = status === 'Applied';
  return (
    <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
      <td className="py-3 px-4 font-bold text-slate-900">{category}</td>
      <td className="py-3 px-4 font-mono text-slate-500 text-xs">{oldA}</td>
      <td className="py-3 px-4 font-mono font-bold text-sky-600 text-xs">{newA}</td>
      <td className="py-3 px-4 text-xs text-slate-600 font-medium">{metric}</td>
      <td className="py-3 px-4 text-right">
        <span className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider border ${isApplied ? 'text-emerald-700 bg-emerald-50 border-emerald-200' : 'text-slate-600 bg-slate-50 border-slate-200'}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}