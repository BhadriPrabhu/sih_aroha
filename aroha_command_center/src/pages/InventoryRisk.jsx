import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { ShieldAlert, Package, Activity, AlertOctagon, TrendingUp, Plus, Loader2, Check, Download } from 'lucide-react';

// Mock data: Breaking down the 5-factor criticality score for top critical items
const riskBreakdownData = [
  { name: 'Diesel (Bharati)', urgency: 0.35, leadTime: 0.25, expedition: 0.20, uncertainty: 0.14, total: 0.94 },
  { name: 'Med Kit (Maitri)', urgency: 0.40, leadTime: 0.15, expedition: 0.10, uncertainty: 0.05, total: 0.70 },
  { name: 'Gen. Spares', urgency: 0.10, leadTime: 0.30, expedition: 0.05, uncertainty: 0.20, total: 0.65 },
  { name: 'Ration Pack B', urgency: 0.25, leadTime: 0.10, expedition: 0.15, uncertainty: 0.08, total: 0.58 },
];

export default function InventoryRisk() {

  const [exportState, setExportState] = useState('idle');
  const [addState, setAddState] = useState('idle');

  const handleExport = () => {
    if (exportState === 'running') return;
    setExportState('running');
    setTimeout(() => {
      setExportState('success');
      setTimeout(() => setExportState('idle'), 3000);
    }, 1500);
  };

  const handleAddStock = () => {
    if (addState === 'running') return;
    setAddState('running');
    setTimeout(() => {
      setAddState('success');
      setTimeout(() => setAddState('idle'), 3000);
    }, 1000);
  };

  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">

        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-1">Inventory & Risk Analysis</h1>
            <p className="text-sm font-medium text-slate-500">5-factor criticality scoring and demand forecasting evaluation.</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={handleExport}
              className="bg-white border border-slate-200 text-slate-700 px-4 py-2 rounded-md text-sm font-semibold shadow-sm hover:bg-slate-50 transition-colors focus:outline-none focus:ring-2 focus:ring-slate-200 flex items-center justify-center gap-2 min-w-[160px]"
            >
              {exportState === 'idle' && <><Download size={14} /> Export Risk Report</>}
              {exportState === 'running' && <><Loader2 size={14} className="animate-spin text-slate-400" /> Generating...</>}
              {exportState === 'success' && <><Check size={14} className="text-emerald-600" /> Downloaded</>}
            </button>
            <button
              onClick={handleAddStock}
              className={`px-4 py-2 rounded-md text-sm font-semibold shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 flex items-center justify-center gap-2 min-w-[160px] ${addState === 'success' ? 'bg-emerald-600 text-white focus:ring-emerald-500' : 'bg-slate-900 text-white hover:bg-slate-800 focus:ring-slate-800'
                }`}
            >
              {addState === 'idle' && <><Plus size={14} /> Add Manual Stock</>}
              {addState === 'running' && <><Loader2 size={14} className="animate-spin" /> Syncing Node...</>}
              {addState === 'success' && <><Check size={14} /> Synced</>}
            </button>
          </div>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <KpiCard title="Total Unique Items" value="1,402" icon={<Package size={18} />} />
          <KpiCard title="Items at High Risk" value="24" subtitle="Score > 0.85" icon={<ShieldAlert size={18} className="text-rose-600" />} alert />
          <KpiCard title="Intermittent Demand" value="315" subtitle="Using Croston/SBA" icon={<Activity size={18} />} />
          <KpiCard title="Avg Lead Time Risk" value="0.42" subtitle="Normalized" icon={<AlertOctagon size={18} />} />
        </div>

        {/* Middle Row: Stacked Bar Chart for Risk Factors */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-slate-200 mb-6 flex flex-col">
          <div className="mb-6 border-b border-slate-100 pb-4">
            <h3 className="text-lg font-bold text-slate-900">Criticality Score Breakdown (Top 4 Items)</h3>
            <p className="text-xs font-medium text-slate-500">Visualizing Urgency, Lead Time, Expedition Impact, and Forecast Uncertainty constraints.</p>
          </div>
          <div className="w-full h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={riskBreakdownData} layout="vertical" margin={{ top: 0, right: 30, left: 40, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#E2E8F0" />
                <XAxis type="number" max={1.0} tick={{ fontSize: 11, fill: '#64748B', fontWeight: 500 }} />
                <YAxis dataKey="name" type="category" tick={{ fontSize: 11, fill: '#475569', fontWeight: 600 }} axisLine={false} tickLine={false} />
                <Tooltip cursor={{ fill: '#F8FAFC' }} contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' }} />
                <Legend iconType="square" wrapperStyle={{ fontSize: '11px', paddingTop: '10px', fontWeight: 600, color: '#475569' }} />

                {/* Tactical Industrial Palette */}
                <Bar dataKey="urgency" name="Urgency (1/DOS)" stackId="a" fill="#E11D48" radius={[0, 0, 0, 0]} /> {/* Rose-600 */}
                <Bar dataKey="leadTime" name="Lead Time" stackId="a" fill="#F59E0B" /> {/* Amber-500 */}
                <Bar dataKey="expedition" name="Expedition Impact" stackId="a" fill="#0284C7" /> {/* Sky-600 */}
                <Bar dataKey="uncertainty" name="Forecast Uncertainty" stackId="a" fill="#64748B" radius={[0, 2, 2, 0]} /> {/* Slate-500 */}
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Bottom Row: Global Inventory Register */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-slate-200">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-slate-900">Global Inventory & Forecasting Register</h3>
            <div className="flex gap-2">
              <select className="text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                <option>All Stations</option>
                <option>Bharati Station</option>
                <option>Maitri Station</option>
              </select>
            </div>
          </div>

          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-[12px] font-semibold text-slate-500 border-b border-slate-200 bg-slate-50">
                <th className="py-3 px-4 font-semibold rounded-tl-md">Item & ID</th>
                <th className="py-3 px-4 font-semibold">Station</th>
                <th className="py-3 px-4 font-semibold">Forecast Method</th>
                <th className="py-3 px-4 font-semibold">Days of Supply</th>
                <th className="py-3 px-4 font-semibold rounded-tr-md">Criticality</th>
              </tr>
            </thead>
            <tbody className="text-sm text-slate-700">
              <TableRow
                name="Winter Diesel Bulk" id="INV-F-092" station="Bharati"
                method="Exponential Smoothing" dos="4 Days" score="0.94" alert
              />
              <TableRow
                name="Generator Alternator" id="INV-S-114" station="Maitri"
                method="Croston / SBA" dos="25 Days" score="0.65"
              />
              <TableRow
                name="Amoxicillin (500mg)" id="INV-M-005" station="Bharati"
                method="Exponential Smoothing" dos="112 Days" score="0.22"
              />
              <TableRow
                name="Ice Core Drill Bits" id="INV-E-044" station="Maitri"
                method="Croston / SBA" dos="18 Days" score="0.78" alert
              />
            </tbody>
          </table>
        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components - REFACTORED FOR ENTERPRISE DENSITY
function KpiCard({ title, value, subtitle, icon, alert }) {
  return (
    <div className={`bg-white p-5 rounded-lg border ${alert ? 'border-rose-500 shadow-sm' : 'border-slate-200 shadow-sm'} flex items-start gap-4 relative overflow-hidden`}>
      {alert && <div className="absolute top-0 left-0 w-1 h-full bg-rose-600"></div>}
      <div className={`p-2 border rounded-md ${alert ? 'bg-rose-50 border-rose-200 text-rose-600' : 'bg-slate-50 border-slate-200 text-slate-600'}`}>
        {icon}
      </div>
      <div>
        <h3 className="text-[12px] font-semibold text-slate-500 mb-1">{title}</h3>
        <div className="text-2xl font-bold text-slate-900 tracking-tight leading-none">
          {value}
        </div>
        {subtitle && <p className="text-[12px] text-slate-400 font-medium">{subtitle}</p>}
      </div>
    </div>
  );
}

function TableRow({ name, id, station, method, dos, score, alert }) {
  return (
    <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
      <td className="py-3 px-4">
        <div className="font-semibold text-slate-900">{name}</div>
        <div className="font-mono text-[10px] font-medium text-slate-500 mt-0.5 uppercase">{id}</div>
      </td>
      <td className="py-3 px-4 font-medium text-slate-600">{station}</td>
      <td className="py-3 px-4">
        <div className="flex items-center gap-1.5 text-[12px] font-semibold text-slate-700 inline-flex">
          <TrendingUp size={14} className="text-slate-500" />
          {method}
        </div>
      </td>
      <td className="py-3 px-4 font-medium text-slate-700">{dos}</td>
      <td className="py-3 px-4">
        <div className="flex items-center gap-2">
          <span className={`font-mono font-bold ${alert ? 'text-rose-600' : 'text-slate-900'}`}>{score}</span>
          {alert && <span className="w-1.5 h-1.5 rounded-full bg-rose-600 animate-pulse"></span>}
        </div>
      </td>
    </tr>
  );
}