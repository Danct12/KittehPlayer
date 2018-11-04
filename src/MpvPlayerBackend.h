#ifndef MpvPlayerBackend_H
#define MpvPlayerBackend_H

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

#include <QObject>
#include <QOpenGLContext>
#include <QQuickFramebufferObject>



class MpvRenderer;

class MpvPlayerBackend : public QQuickFramebufferObject
{
    Q_OBJECT
    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class MpvRenderer;

public:
    static void on_update(void *ctx);

    MpvPlayerBackend(QQuickItem * parent = 0);
    virtual ~MpvPlayerBackend();
    virtual Renderer *createRenderer() const;


public slots:
    void launchAboutQt();
    void togglePlayPause();
    void toggleMute();
    void nextAudioTrack();
    void nextVideoTrack();
    void nextSubtitleTrack();
    void prevPlaylistItem();
    void nextPlaylistItem();
    void setVolume(const QVariant& volume);
    void addVolume(const QVariant& volume);
    void loadFile(const QVariant& filename);
    void seek(const QVariant& seekTime);
    void command(const QVariant& params);
    void setProperty(const QString& name, const QVariant& value);
    void setOption(const QString& name, const QVariant& value);
    QVariant getProperty(const QString& name) const;


signals:
    void onUpdate();
    void positionChanged(int value);
    void mpv_events();

private slots:
    void doUpdate();
    void on_mpv_events();

private:
    void handle_mpv_event(mpv_event *event);


};



#endif