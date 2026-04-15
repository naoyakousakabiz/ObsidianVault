import React, { useState } from "react";

// ─── Types ────────────────────────────────────────────────────────────────────

interface Contact {
  id: string;
  firstName: string;
  lastName?: string;
  groupLabel?: string;
  isGroup?: boolean;
  avatarColor: string;
}

interface AppItem {
  id: string;
  name: string;
  icon: string;
  bgColor: string;
}

interface ActionItem {
  id: string;
  name: string;
  icon: string;
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const CONTACTS: Contact[] = [
  { id: "1", firstName: "Herland", lastName: "Antezana", avatarColor: "#4A90D9" },
  { id: "2", firstName: "Rigo", lastName: "Rangel", avatarColor: "#E67E22" },
  {
    id: "3",
    firstName: "Magico",
    groupLabel: "Magico and El...",
    lastName: "2 People",
    isGroup: true,
    avatarColor: "#9B59B6",
  },
  { id: "4", firstName: "Jenny", lastName: "Court", avatarColor: "#27AE60" },
  { id: "5", firstName: "Alejandra", lastName: "Delgado", avatarColor: "#E74C3C" },
];

const APPS: AppItem[] = [
  { id: "airdrop", name: "AirDrop", icon: "📡", bgColor: "#1B7AE0" },
  { id: "messages", name: "Messages", icon: "💬", bgColor: "#34C759" },
  { id: "mail", name: "Mail", icon: "✉️", bgColor: "#007AFF" },
  { id: "notes", name: "Notes", icon: "📝", bgColor: "#FFD60A" },
  { id: "reminders", name: "Reminders", icon: "🔔", bgColor: "#FF3B30" },
];

const ACTIONS: ActionItem[] = [
  { id: "copy", name: "Copy", icon: "📋" },
  { id: "favorites", name: "Add to Favorites", icon: "⭐" },
  { id: "reading", name: "Add to Reading List", icon: "👓" },
  { id: "bookmark", name: "Add Bookmark", icon: "🔖" },
];

// ─── Sub-components ───────────────────────────────────────────────────────────

function WindowControls() {
  return (
    <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
      {(["#FF5F57", "#FEBC2F", "#27C840"] as const).map((color, i) => (
        <div
          key={i}
          style={{
            width: 12,
            height: 12,
            borderRadius: "50%",
            backgroundColor: color,
            cursor: "pointer",
          }}
        />
      ))}
    </div>
  );
}

function ToolbarButton({ children }: { children: React.ReactNode }) {
  const [hovered, setHovered] = useState(false);
  return (
    <button
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        width: 32,
        height: 32,
        borderRadius: 8,
        border: "none",
        background: hovered ? "rgba(0,0,0,0.08)" : "transparent",
        cursor: "pointer",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: 16,
        color: "#1A1A1A",
        transition: "background 0.15s",
      }}
    >
      {children}
    </button>
  );
}

function SearchField() {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 6,
        backgroundColor: "rgba(0,0,0,0.06)",
        borderRadius: 8,
        padding: "4px 10px",
        width: 180,
        height: 28,
      }}
    >
      <span style={{ fontSize: 13, color: "#727272" }}>🔍</span>
      <span style={{ fontSize: 13, color: "#BFBFBF", flex: 1 }}>Search</span>
    </div>
  );
}

function Toolbar({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <div
      style={{
        height: 54,
        backgroundColor: "rgba(245,245,245,0.85)",
        backdropFilter: "blur(20px)",
        borderBottom: "1px solid rgba(0,0,0,0.1)",
        display: "flex",
        alignItems: "center",
        padding: "0 16px",
        gap: 8,
        flexShrink: 0,
      }}
    >
      {/* Leading */}
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <div style={{ paddingRight: 8 }}>
          <WindowControls />
        </div>
        <ToolbarButton>←</ToolbarButton>
        <ToolbarButton>⊞</ToolbarButton>
      </div>

      {/* Center – title */}
      <div
        style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          lineHeight: 1.2,
        }}
      >
        <span style={{ fontSize: 15, fontWeight: 590, color: "#1A1A1A" }}>{title}</span>
        <span style={{ fontSize: 12, color: "#727272" }}>{subtitle}</span>
      </div>

      {/* Trailing */}
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        <ToolbarButton>⊙</ToolbarButton>
        <ToolbarButton>↑</ToolbarButton>
        <SearchField />
      </div>
    </div>
  );
}

function Avatar({ contact }: { contact: Contact }) {
  if (contact.isGroup) {
    return (
      <div style={{ position: "relative", width: 70, height: 70 }}>
        <div
          style={{
            position: "absolute",
            bottom: 0,
            left: 0,
            width: 37,
            height: 37,
            borderRadius: "50%",
            backgroundColor: contact.avatarColor,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 14,
            color: "#fff",
            fontWeight: 600,
            border: "2px solid #fff",
          }}
        >
          {contact.firstName[0]}
        </div>
        <div
          style={{
            position: "absolute",
            top: 0,
            right: 0,
            width: 22,
            height: 22,
            borderRadius: "50%",
            backgroundColor: "#7B68EE",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 10,
            color: "#fff",
            fontWeight: 600,
            border: "2px solid #fff",
          }}
        >
          E
        </div>
      </div>
    );
  }
  return (
    <div
      style={{
        width: 70,
        height: 70,
        borderRadius: "50%",
        backgroundColor: contact.avatarColor,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: 22,
        color: "#fff",
        fontWeight: 700,
      }}
    >
      {contact.firstName[0]}
    </div>
  );
}

function ContactCard({ contact }: { contact: Contact }) {
  return (
    <div
      style={{
        width: 78,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 8,
        cursor: "pointer",
        flexShrink: 0,
      }}
    >
      <div style={{ position: "relative" }}>
        <Avatar contact={contact} />
        <div
          style={{
            position: "absolute",
            bottom: 0,
            right: 0,
            width: 20,
            height: 20,
            borderRadius: "50%",
            backgroundColor: "#007AFF",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 12,
            color: "#fff",
            border: "2px solid #fff",
          }}
        >
          +
        </div>
      </div>
      {contact.isGroup ? (
        <div style={{ textAlign: "center" }}>
          <div style={{ fontSize: 10, color: "#1A1A1A" }}>{contact.groupLabel}</div>
          <div style={{ fontSize: 12, color: "#1A1A1A" }}>{contact.lastName}</div>
        </div>
      ) : (
        <div style={{ textAlign: "center" }}>
          <div style={{ fontSize: 12, color: "#1A1A1A" }}>{contact.firstName}</div>
          <div style={{ fontSize: 12, color: "#1A1A1A" }}>{contact.lastName}</div>
        </div>
      )}
    </div>
  );
}

function AppIconCard({ app }: { app: AppItem }) {
  return (
    <div
      style={{
        width: 78,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 6,
        cursor: "pointer",
        flexShrink: 0,
      }}
    >
      <div
        style={{
          width: 70,
          height: 70,
          borderRadius: 16,
          backgroundColor: app.bgColor,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 32,
        }}
      >
        {app.icon}
      </div>
      <span style={{ fontSize: 11, color: "#1A1A1A", textAlign: "center" }}>{app.name}</span>
    </div>
  );
}

function Separator() {
  return (
    <div
      style={{
        height: 1,
        backgroundColor: "rgba(0,0,0,0.1)",
        margin: "0 24px",
      }}
    />
  );
}

function ActionRow({ action, isLast }: { action: ActionItem; isLast: boolean }) {
  const [hovered, setHovered] = useState(false);
  return (
    <>
      <div
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
        style={{
          display: "flex",
          alignItems: "center",
          gap: 14,
          padding: "12px 20px",
          cursor: "pointer",
          backgroundColor: hovered ? "rgba(0,0,0,0.04)" : "transparent",
          transition: "background 0.15s",
        }}
      >
        <div
          style={{
            width: 34,
            height: 34,
            borderRadius: 8,
            backgroundColor: "rgba(0,0,0,0.06)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 18,
          }}
        >
          {action.icon}
        </div>
        <span style={{ fontSize: 15, color: "#1A1A1A" }}>{action.name}</span>
      </div>
      {!isLast && <Separator />}
    </>
  );
}

// ─── Activity View Sheet ──────────────────────────────────────────────────────

interface ActivityViewSheetProps {
  title: string;
  subtitle: string;
  onClose: () => void;
}

function ActivityViewSheet({ title, subtitle, onClose }: ActivityViewSheetProps) {
  return (
    <div
      style={{
        position: "absolute",
        top: 54 + 20,
        right: 20,
        width: 402,
        maxHeight: 734,
        backgroundColor: "rgba(255,255,255,0.88)",
        backdropFilter: "blur(40px) saturate(200%)",
        WebkitBackdropFilter: "blur(40px) saturate(200%)",
        borderRadius: 14,
        boxShadow:
          "0 20px 60px rgba(0,0,0,0.2), 0 0 0 0.5px rgba(0,0,0,0.12)",
        overflow: "hidden",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Popover arrow */}
      <div
        style={{
          position: "absolute",
          top: -13,
          right: 40,
          width: 0,
          height: 0,
          borderLeft: "14px solid transparent",
          borderRight: "14px solid transparent",
          borderBottom: "14px solid rgba(255,255,255,0.88)",
          filter: "drop-shadow(0 -2px 2px rgba(0,0,0,0.08))",
        }}
      />

      {/* Header */}
      <div style={{ padding: "20px 20px 16px", position: "relative" }}>
        <div style={{ display: "flex", gap: 16, alignItems: "flex-start" }}>
          {/* Thumbnail */}
          <div
            style={{
              width: 64,
              height: 64,
              borderRadius: 12,
              backgroundColor: "#E8F0FE",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 28,
              flexShrink: 0,
            }}
          >
            📄
          </div>

          {/* Middle */}
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ marginBottom: 8 }}>
              <div style={{ fontSize: 15, fontWeight: 510, color: "#1A1A1A" }}>{title}</div>
              <div style={{ fontSize: 13, color: "#727272" }}>{subtitle}</div>
            </div>

            {/* Collaborate button */}
            <button
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                padding: "7px 14px",
                borderRadius: 8,
                border: "none",
                backgroundColor: "rgba(0,0,0,0.06)",
                cursor: "pointer",
                fontSize: 15,
                fontWeight: 510,
                color: "#1A1A1A",
              }}
            >
              <span>👥</span>
              <span>Collaborate</span>
              <span style={{ color: "#007AFF", fontSize: 12 }}>›</span>
            </button>

            {/* Secondary menu */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 4,
                marginTop: 6,
                cursor: "pointer",
              }}
            >
              <span style={{ fontSize: 13, color: "#1A1A1A" }}>Only invited people can edit.</span>
              <span style={{ fontSize: 13, color: "#007AFF" }}>›</span>
            </div>
          </div>
        </div>

        {/* Close button */}
        <button
          onClick={onClose}
          style={{
            position: "absolute",
            top: 16,
            right: 16,
            width: 30,
            height: 30,
            borderRadius: "50%",
            border: "none",
            backgroundColor: "rgba(0,0,0,0.08)",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 14,
            color: "#1A1A1A",
          }}
        >
          ✕
        </button>
      </div>

      <Separator />

      {/* Contacts Row */}
      <div
        style={{
          padding: "16px 12px",
          display: "flex",
          gap: 4,
          overflowX: "auto",
          scrollbarWidth: "none",
        }}
      >
        {CONTACTS.map((contact) => (
          <ContactCard key={contact.id} contact={contact} />
        ))}
      </div>

      <Separator />

      {/* App Icon Row */}
      <div
        style={{
          padding: "16px 12px",
          display: "flex",
          gap: 4,
          overflowX: "auto",
          scrollbarWidth: "none",
        }}
      >
        {APPS.map((app) => (
          <AppIconCard key={app.id} app={app} />
        ))}
      </div>

      <Separator />

      {/* Actions */}
      <div style={{ paddingTop: 4, paddingBottom: 4 }}>
        {ACTIONS.map((action, i) => (
          <ActionRow key={action.id} action={action} isLast={i === ACTIONS.length - 1} />
        ))}
      </div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function ActivityView() {
  const [showSheet, setShowSheet] = useState(true);

  return (
    <div
      style={{
        width: 1210,
        height: 834,
        backgroundColor: "#FFFFFF",
        borderRadius: 12,
        overflow: "hidden",
        boxShadow: "0 30px 80px rgba(0,0,0,0.3)",
        display: "flex",
        flexDirection: "column",
        position: "relative",
        fontFamily:
          '-apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif',
      }}
    >
      {/* Toolbar */}
      <Toolbar title="Title" subtitle="Subtitle" />

      {/* Content Area */}
      <div
        style={{
          flex: 1,
          backgroundColor: "#F5F5F5",
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Share button to toggle sheet */}
        <button
          onClick={() => setShowSheet((v) => !v)}
          style={{
            position: "absolute",
            top: 20,
            right: 20,
            padding: "8px 16px",
            borderRadius: 8,
            border: "none",
            backgroundColor: "#007AFF",
            color: "#fff",
            fontSize: 14,
            fontWeight: 510,
            cursor: "pointer",
          }}
        >
          {showSheet ? "Close Share Sheet" : "↑ Share"}
        </button>

        {/* Activity View Sheet */}
        {showSheet && (
          <ActivityViewSheet
            title="Title"
            subtitle="Subtitle"
            onClose={() => setShowSheet(false)}
          />
        )}
      </div>
    </div>
  );
}
