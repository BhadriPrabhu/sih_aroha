import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { ShieldAlert, Package, Activity, AlertOctagon, TrendingUp } from 'lucide-react';

// Mock data: Breaking down the 5-factor criticality score for top critical items
const riskBreakdownData = [
  { name: 'Diesel (Bharati)', urgency: 0.35, leadTime: 0.25, expedition: 0.20, uncertainty: 0.14, total: 0.94 },
  { name: 'Med Kit (Maitri)', urgency: 0.40, leadTime: 0.15, expedition: 0.10, uncertainty: 0.05, total: 0.70 },
  { name: 'Gen. Spares', urgency: 0.10, leadTime: 0.30, expedition: 0.05, uncertainty: 0.20, total: 0.65 },
  { name: 'Ration Pack B', urgency: 0.25, leadTime: 0.10, expedition: 0.15, uncertainty: 0.08, total: 0.58 },
];

export default function InventoryRisk() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Page Header */}
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 mb-1">Inventory & Risk Analysis</h1>
            <p className="text-sm text-slate-500">5-factor criticality scoring and demand forecasting evaluation.</p>
          </div>
          <div className="flex gap-3">
             <button className="bg-white border border-slate-200 text-slate-700 px-4 py-2 rounded-xl text-sm font-semibold shadow-sm hover:bg-slate-50 transition-colors">
              Export Risk Report
            </button>
            <button className="bg-[#6D28D9] text-white px-4 py-2 rounded-xl text-sm font-semibold shadow-md shadow-purple-900/20 hover:bg-purple-700 transition-colors">
              + Add Manual Stock
            </button>
          </div>
        </div>

        {/* Top KPI Row */}
        <div className="grid grid-cols-4 gap-6 mb-6">
          <KpiCard title="Total Unique Items" value="1,402" icon={<Package size={20} className="text-blue-600"/>} bg="bg-blue-100" />
          <KpiCard title="Items at High Risk" value="24" subtitle="Score > 0.85" icon={<ShieldAlert size={20} className="text-red-600"/>} bg="bg-red-100" />
          <KpiCard title="Intermittent Demand" value="315" subtitle="Using Croston/SBA" icon={<Activity size={20} className="text-purple-600"/>} bg="bg-purple-100" />
          <KpiCard title="Avg Lead Time Risk" value="0.42" subtitle="Normalized" icon={<AlertOctagon size={20} className="text-amber-600"/>} bg="bg-amber-100" />
        </div>

        {/* Middle Row: Stacked Bar Chart for Risk Factors */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 mb-6">
          <div className="mb-4">
            <h3 className="text-base font-bold text-slate-800">Criticality Score Breakdown (Top 4 Items)</h3>
            <p className="text-xs text-slate-500">Visualizing Urgency, Lead Time, Expedition Impact, and Forecast Uncertainty constraints.</p>
          </div>
          <div className="w-full h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={riskBreakdownData} layout="vertical" margin={{ top: 0, right: 30, left: 40, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" />
                <XAxis type="number" max={1.0} tick={{fontSize: 12, fill: '#94a3b8'}} />
                <YAxis dataKey="name" type="category" tick={{fontSize: 12, fill: '#64748b', fontWeight: 500}} axisLine={false} tickLine={false} />
                <Tooltip cursor={{fill: '#f8fafc'}} contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: '12px', paddingTop: '10px' }} />
                <Bar dataKey="urgency" name="Urgency (1/DOS)" stackId="a" fill="#ef4444" radius={[0, 0, 0, 0]} />
                <Bar dataKey="leadTime" name="Lead Time" stackId="a" fill="#f59e0b" />
                <Bar dataKey="expedition" name="Expedition Impact" stackId="a" fill="#6D28D9" />
                <Bar dataKey="uncertainty" name="Forecast Uncertainty" stackId="a" fill="#3b82f6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Bottom Row: Global Inventory Register */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
           <div className="flex justify-between items-center mb-6">
              <h3 className="text-base font-bold text-slate-800">Global Inventory & Forecasting Register</h3>
              <div className="flex gap-2">
                 <select className="text-xs bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-slate-600 outline-none font-medium">
                    <option>All Stations</option>
                    <option>Bharati Station</option>
                    <option>Maitri Station</option>
                 </select>
              </div>
           </div>
           
           <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-xs font-semibold text-slate-400 border-b border-slate-100 uppercase tracking-wider">
                <th className="pb-3 font-medium">Item & ID</th>
                <th className="pb-3 font-medium">Station</th>
                <th className="pb-3 font-medium">Forecast Method</th>
                <th className="pb-3 font-medium">Days of Supply</th>
                <th className="pb-3 font-medium">Criticality</th>
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

// Sub-components
function KpiCard({ title, value, subtitle, icon, bg }) {
  return (
    <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4">
      <div className={`p-3 rounded-xl ${bg}`}>
        {icon}
      </div>
      <div>
        <h3 className="text-xs font-medium text-slate-500 mb-0.5">{title}</h3>
        <div className="text-2xl font-bold text-slate-800 leading-none">{value}</div>
        {subtitle && <p className="text-[10px] text-slate-400 mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}

function TableRow({ name, id, station, method, dos, score, alert }) {
  return (
    <tr className="border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
      <td className="py-4">
        <div className="font-semibold text-slate-800">{name}</div>
        <div className="font-mono text-[10px] text-slate-400 mt-0.5">{id}</div>
      </td>
      <td className="py-4 font-medium text-slate-600">{station}</td>
      <td className="py-4">
        <div className="flex items-center gap-1.5 text-xs font-medium text-purple-700 bg-purple-50 px-2 py-1 rounded-md inline-flex border border-purple-100">
           <TrendingUp size={14} />
           {method}
        </div>
      </td>
      <td className="py-4 font-medium text-slate-700">{dos}</td>
      <td className="py-4">
        <div className="flex items-center gap-2">
           <span className={`font-bold ${alert ? 'text-red-600' : 'text-slate-700'}`}>{score}</span>
           {alert && <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>}
        </div>
      </td>
    </tr>
  );
}