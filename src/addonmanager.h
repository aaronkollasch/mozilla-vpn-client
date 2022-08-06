/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef ADDONMANAGER_H
#define ADDONMANAGER_H

#include "addons/addon.h"  // required for the signal

#include <QJSValue>
#include <QMap>
#include <QAbstractListModel>

class QDir;

class AddonManager final : public QAbstractListModel {
  Q_OBJECT
  Q_DISABLE_COPY_MOVE(AddonManager)

  Q_PROPERTY(
      bool loadCompleted MEMBER m_loadCompleted NOTIFY loadCompletedChanged)

 public:
  Q_INVOKABLE Addon* pick(QJSValue filterCallback) const;

  Q_INVOKABLE QJSValue reduce(QJSValue callback, QJSValue initialValue) const;

  enum ModelRoles {
    AddonRole = Qt::UserRole + 1,
  };

  static AddonManager* instance();

  ~AddonManager();

  void updateIndex(const QByteArray& index, const QByteArray& indexSignature);

  void storeAndLoadAddon(const QByteArray& addonData, const QString& addonId,
                         const QByteArray& sha256);

  bool loadManifest(const QString& addonManifestFileName);

  void unload(const QString& addonId);

  void retranslate();

  void forEach(std::function<void(Addon* addon)>&& callback);

#ifdef UNIT_TEST
  QStringList addonIds() const;
#endif

 private:
  explicit AddonManager(QObject* parent);

  void initialize();

  bool validateIndex(const QByteArray& index, const QByteArray& indexSignature);
  bool validateAndLoad(const QString& addonId, const QByteArray& sha256,
                       bool checkSha256 = true);

  static bool addonDir(QDir* dir);
  static bool readIndex(QByteArray& index, QByteArray& indexSignature);
  static void writeIndex(const QByteArray& index,
                         const QByteArray& indexSignature);

  static void removeAddon(const QString& addonId);

  // QAbstractListModel methods

  QHash<int, QByteArray> roleNames() const override;

  int rowCount(const QModelIndex&) const override;

  QVariant data(const QModelIndex& index, int role) const override;

 signals:
  void runAddon(Addon* addon);

  void loadCompletedChanged();

 private:
  // This struct can be partially empty in case the sha does not match, or the
  // addon does not need to be loaded for unmatched conditions.
  struct AddonData {
    QByteArray m_sha256;
    QString m_addonId;
    Addon* m_addon;
  };

  QMap<QString, AddonData> m_addons;

  bool m_loadCompleted = false;
};

#endif  // ADDONMANAGER_H
