import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { LineChart, Line, ResponsiveContainer, CartesianGrid, XAxis, Tooltip } from 'recharts';
import { Anchor, Activity, Box, Radio, TrendingDown, TrendingUp, AlertCircle, CheckCircle2 } from 'lucide-react';

// Mock Data
const trendData = [ { name: 'Mon', val: 0.6 }, { name: 'Tue', val: 0.65 }, { name: 'Wed', val: 0.72 }, { name: 'Thu', val: 0.8 }, { name: 'Fri', val: 0.89 }, { name: 'Sat', val: 0.94 } ];

export default function CommandCenterHome() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Top Row: 2x2 KPIs on left, Wide Chart on right */}
        <div className="grid grid-cols-12 gap-6 mb-6">
          
          {/* Left Side: 2x2 Grid for KPIs */}
          <div className="col-span-7 grid grid-cols-2 gap-6">
            <KpiCard 
              title="Peak Criticality" 
              value="0.94" 
              subtitle="Bharati Station"
              trend="up"
              trendValue="12% from yesterday"
              icon={<Activity size={20} className="text-purple-600" />}
              iconBg="bg-purple-100"
            />
            <KpiCard 
              title="Forecast MAE" 
              value="3.8%" 
              subtitle="Global Average"
              trend="down"
              trendValue="0.4% from last week"
              icon={<TrendingDown size={20} className="text-emerald-600" />}
              iconBg="bg-emerald-100"
            />
            <KpiCard 
              title="Cargo Capacity Util." 
              value="92%" 
              subtitle="Planned Resupply"
              trend="up"
              trendValue="Optimized via Knapsack"
              icon={<Box size={20} className="text-blue-600" />}
              iconBg="bg-blue-100"
            />
            <KpiCard 
              title="Active Escalations" 
              value="2" 
              subtitle="Burst Channel"
              trend="up"
              trendValue="Immediate Action Req."
              icon={<AlertCircle size={20} className="text-red-600" />}
              iconBg="bg-red-100"
            />
          </div>

          {/* Right Side: Wide Chart (Replaces "Recurring Revenue") */}
          <div className="col-span-5 bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col">
            <div className="flex justify-between items-start mb-6">
              <div>
                <h3 className="text-slate-500 text-sm font-medium">Criticality Trajectory</h3>
                <div className="text-2xl font-bold text-slate-800 mt-1">0.94 <span className="text-xs font-semibold text-red-500 ml-2 bg-red-50 px-2 py-1 rounded-md text-nowrap">High Risk ↗</span></div>
              </div>
              <select className="text-xs bg-slate-50 border border-slate-200 rounded-md px-2 py-1 text-slate-600 outline-none">
                <option>This Week</option>
              </select>
            </div>
            <div className="flex-1 w-full min-h-[150px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={trendData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize: 10, fill: '#94a3b8'}} dy={10} />
                  <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                  <Line type="monotone" dataKey="val" stroke="#6D28D9" strokeWidth={3} dot={{r: 4, fill: '#6D28D9', strokeWidth: 2, stroke: '#fff'}} activeDot={{r: 6}} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Bottom Row: Active Plans Table + Dark Status Card */}
        <div className="grid grid-cols-12 gap-6">
          
          {/* Main Table Area */}
          <div className="col-span-8 bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
             <div className="flex justify-between items-center mb-6">
                <h3 className="text-base font-bold text-slate-800">Active Resupply Plans (Knapsack Optimized)</h3>
                <button className="text-sm text-purple-600 font-medium hover:text-purple-700">View All</button>
             </div>
             
             <table className="w-full text-left border-collapse">
              <thead>
                <tr className="text-xs font-semibold text-slate-400 border-b border-slate-100">
                  <th className="pb-3 font-medium">Plan ID</th>
                  <th className="pb-3 font-medium">Target Station</th>
                  <th className="pb-3 font-medium">Fulfillment</th>
                  <th className="pb-3 font-medium">Residual Risk</th>
                  <th className="pb-3 font-medium">Status</th>
                </tr>
              </thead>
              <tbody className="text-sm text-slate-700">
                <TableRow id="OPT-2026-BHA-01" target="Bharati Station" fulfillment="80%" risk="High" status="Planned" />
                <TableRow id="OPT-2026-MAI-04" target="Maitri Station" fulfillment="100%" risk="Low" status="In Transit" />
                <TableRow id="OPT-2026-BHA-02" target="Bharati Station" fulfillment="92%" risk="Med" status="Delivered" />
              </tbody>
            </table>
          </div>

          {/* Dark Highlight Card (Matches the "Customer Growth" purple card in the Dribbble image) */}
          <div className="col-span-4 bg-gradient-to-br from-[#1A103C] to-[#2D1B69] rounded-2xl p-6 text-white shadow-xl relative overflow-hidden flex flex-col justify-between">
            {/* Background decorative circles */}
            <div className="absolute -top-12 -right-12 w-32 h-32 bg-purple-500/20 rounded-full blur-2xl"></div>
            <div className="absolute bottom-0 right-0 w-24 h-24 bg-blue-500/20 rounded-full blur-xl"></div>
            
            <div>
              <div className="flex items-center gap-2 text-purple-200 mb-6 text-sm font-medium">
                <Radio size={16} className="text-purple-400" /> SATCOM Delta Sync
              </div>
              <div className="text-4xl font-bold text-white mb-2 tracking-tight">
                99.8% <span className="text-sm font-semibold bg-emerald-500/20 text-emerald-300 px-2 py-1 rounded-md ml-2 align-middle">Online</span>
              </div>
              <p className="text-xs text-purple-200/70">Packet success rate across all field facilities.</p>
            </div>
            
            <div className="mt-8 bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/10">
              <div className="flex justify-between items-center text-sm">
                <span className="text-purple-100">Next Sync Window</span>
                <span className="font-semibold text-white">14:00 UTC</span>
              </div>
              <div className="w-full bg-white/10 rounded-full h-1.5 mt-3">
                <div className="bg-purple-400 h-1.5 rounded-full w-[70%]"></div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components
function KpiCard({ title, value, subtitle, trend, trendValue, icon, iconBg }) {
  const isUp = trend === 'up';
  return (
    <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
      <div className="flex justify-between items-start mb-4">
        <div className={`p-2.5 rounded-xl ${iconBg}`}>
          {icon}
        </div>
        <div className="text-right">
           <h3 className="text-xs font-medium text-slate-400">{title}</h3>
           <p className="text-[10px] text-slate-400 mt-0.5">{subtitle}</p>
        </div>
      </div>
      <div className="mt-2">
        <span className="text-2xl font-bold text-slate-800">{value}</span>
        <div className="flex items-center gap-1.5 mt-1 text-[11px] font-medium">
          <span className={isUp ? 'text-emerald-500' : 'text-red-500'}>
             {isUp ? '↗' : '↘'}
          </span>
          <span className="text-slate-500">{trendValue}</span>
        </div>
      </div>
    </div>
  );
}

function TableRow({ id, target, fulfillment, risk, status }) {
  const getRiskIcon = (level) => {
    if (level === 'Low') return <CheckCircle2 size={14} className="text-emerald-500" />;
    if (level === 'Med') return <AlertCircle size={14} className="text-amber-500" />;
    return <AlertCircle size={14} className="text-red-500" />;
  };

  const getStatusColor = (s) => {
    if (s === 'Planned') return 'bg-amber-50 text-amber-600 border border-amber-100';
    if (s === 'In Transit') return 'bg-blue-50 text-blue-600 border border-blue-100';
    return 'bg-emerald-50 text-emerald-600 border border-emerald-100';
  };

  return (
    <tr className="border-b border-slate-50 hover:bg-slate-50/50 transition-colors">
      <td className="py-4">
        <div className="font-mono text-xs font-semibold text-slate-800">{id}</div>
      </td>
      <td className="py-4 text-sm font-medium text-slate-600">{target}</td>
      <td className="py-4 text-sm font-medium text-slate-700">{fulfillment}</td>
      <td className="py-4">
        <div className="flex items-center gap-1.5 text-xs text-slate-500 font-medium">
          {getRiskIcon(risk)} {risk}
        </div>
      </td>
      <td className="py-4">
        <span className={`px-3 py-1 rounded-full text-[11px] font-bold ${getStatusColor(status)}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}