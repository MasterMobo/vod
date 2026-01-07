package com.vod.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.vod.entities.Video;
import com.vod.entities.VideoRepository;

@Service
public class VideoService {
    private final VideoRepository videoRepository;

    public VideoService(VideoRepository videoRepository) {
        this.videoRepository = videoRepository;
    }

    public List<Video> getAllVideos() {
        return videoRepository.findAll();
    }
}
