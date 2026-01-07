package com.vod.controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vod.dto.response.GetVideosResponse;
import com.vod.entities.Video;
import com.vod.services.VideoService;

@RestController
@RequestMapping("/api/videos")
public class VideoController {
    private final VideoService videoService;

    public VideoController(VideoService videoService) {
        this.videoService = videoService;
    }

    @GetMapping
    public ResponseEntity<GetVideosResponse> getAllVideos() {
        List<Video> videos = videoService.getAllVideos();
        return ResponseEntity.ok(new GetVideosResponse(videos));
    }
}
