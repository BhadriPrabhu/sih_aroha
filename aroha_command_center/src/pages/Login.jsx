import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldCheck, User, Lock, Activity, Server, Radio, Loader2, Globe, Satellite } from 'lucide-react';
import { DotLottieReact } from '@lottiefiles/dotlottie-react';

export default function Login() {
    const navigate = useNavigate();
    const [authStatus, setAuthStatus] = useState('idle'); // 'idle' | 'authenticating'
    const [role, setRole] = useState('LOGISTICS_COMMANDER');

    const handleLogin = (e) => {
        e.preventDefault();
        setAuthStatus('authenticating');

        // Simulate secure handshake & clearance verification
        setTimeout(() => {
            setAuthStatus('idle');
            // Route to the dashboard upon success
            // In a real app, you'd store the JWT and Role in Context/Zustand here
            navigate('/');
        }, 1800);
    };

    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6 font-sans">
            {/* Main Auth Container - Crisp Geometry, No Drop Shadows, 1px Border */}
            <div className="max-w-5xl w-full bg-white border border-slate-200 rounded-lg flex overflow-hidden shadow-sm min-h-[600px]">

                {/* Left Side: Tactical SATCOM Visualization (Replacing the cartoon) */}
                <div className="hidden lg:flex w-1/2 bg-slate-900 border-r border-slate-800 p-8 flex-col justify-between relative overflow-hidden">
                    {/* Abstract Grid Background */}
                    <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(#CBD5E1 1px, transparent 1px)', backgroundSize: '24px 24px' }}></div>

                    <div className="relative z-10">
                        <div className="flex items-center gap-3">
                            <span className="font-bold text-3xl text-slate-100 tracking-tight uppercase">AROHA</span>
                        </div>
                        <p className="text-sm font-medium text-slate-400 tracking-wider leading-relaxed">
                            Integrated Polar Expedition Logistics &<br />Asset Management System
                        </p>
                    </div>

                    <div className="relative z-10 flex justify-center w-full px-2">
                        <div className="rounded-xl border border-sky-500/20 bg-slate-950/30 p-2 shadow-[0_0_30px_rgba(56,189,248,0.08)] backdrop-blur-xs">
                            <DotLottieReact
                                src="/dashboard.lottie"
                                loop
                                autoplay
                                className="w-full h-auto object-contain opacity-90"
                            />
                        </div>
                    </div>

                    <div className="relative z-10">
                        <div className="flex items-center gap-2 text-emerald-500 mb-1">
                            <ShieldCheck size={16} />
                            <span className="text-[10px] font-bold uppercase tracking-widest">End-to-End Encrypted</span>
                        </div>
                        <p className="text-[10px] text-slate-500 font-mono">SIH26062 • Unauthorized access is strictly prohibited.</p>
                    </div>
                </div>

                {/* Right Side: Authentication Form */}
                <div className="w-full lg:w-1/2 p-12 flex flex-col justify-center bg-white">
                    <div className="max-w-md w-full mx-auto">

                        <div className="mb-8">
                            <h2 className="text-3xl font-bold text-slate-900 tracking-tight mb-2">Secure Access</h2>
                            <p className="text-sm font-medium text-slate-500 tracking-wider">Please authenticate with your operational credentials.</p>
                        </div>

                        <form onSubmit={handleLogin} className="space-y-5">

                            {/* Role / Clearance Selector */}
                            <div>
                                <label className="block text-[12px] font-bold text-slate-700 uppercase tracking-wider mb-1.5">Clearance Level</label>
                                <select
                                    value={role}
                                    onChange={(e) => setRole(e.target.value)}
                                    className="w-full bg-slate-50 border border-slate-200 text-slate-900 text-sm font-medium rounded-md px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500 focus:bg-white transition-all appearance-none cursor-pointer"
                                >
                                    <option value="NCPOR_DIRECTOR">NCPOR Director (Super Admin)</option>
                                    <option value="LOGISTICS_COMMANDER">Logistics Commander (Admin)</option>
                                    <option value="STATION_COMMANDER_BHA">Station Commander</option>
                                    <option value="EXPEDITION_LEAD">Expedition Leader</option>
                                </select>
                            </div>

                            {/* Operator ID */}
                            <div>
                                <label className="block text-[12px] font-bold text-slate-700 uppercase tracking-wider mb-1.5">Operator ID / Email</label>
                                <div className="relative">
                                    <User size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                                    <input
                                        type="text"
                                        required
                                        placeholder="e.g. cmdr.alex@ncpor.res.in"
                                        className="w-full bg-slate-50 border border-slate-200 text-slate-900 text-sm rounded-md pl-10 pr-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500 focus:bg-white transition-all"
                                    />
                                </div>
                            </div>

                            {/* Access Key */}
                            <div>
                                <label className="block text-[12px] font-bold text-slate-700 uppercase tracking-wider mb-1.5">Access Key</label>
                                <div className="relative">
                                    <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                                    <input
                                        type="password"
                                        required
                                        placeholder="••••••••••••"
                                        className="w-full bg-slate-50 border border-slate-200 text-slate-900 text-sm rounded-md pl-10 pr-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500 focus:bg-white transition-all"
                                    />
                                </div>
                            </div>

                            {/* Submit Button */}
                            <button
                                type="submit"
                                disabled={authStatus === 'authenticating'}
                                className={`w-full mt-4 flex items-center justify-center gap-2 py-2.5 rounded-md text-sm font-bold shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 ${authStatus === 'authenticating'
                                        ? 'bg-slate-100 text-slate-400 border border-slate-200 cursor-not-allowed'
                                        : 'bg-slate-900 text-white hover:bg-slate-800'
                                    }`}
                            >
                                {authStatus === 'authenticating' ? (
                                    <><Loader2 size={16} className="animate-spin" /> Verifying Clearance...</>
                                ) : (
                                    'Initialize Session'
                                )}
                            </button>
                        </form>

                    </div>
                </div>
            </div>
        </div>
    );
}